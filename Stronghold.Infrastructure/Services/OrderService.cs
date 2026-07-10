using Mapster;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Stripe;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Messaging;
using Stronghold.Application.DTOs.Orders;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Interfaces;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Services;

public class OrderService : BaseService<Order, OrderResponse, OrderSearch>, IOrderService
{
    private const string Currency = "bam";

    private readonly ICurrentUserService _currentUser;
    private readonly IEmailPublisher _emailPublisher;
    private readonly ILogger<OrderService> _logger;
    private readonly ActivityLogInterceptor _activityLogInterceptor;
    private readonly StripeClient _stripe;
    private readonly string _publishableKey;

    public OrderService(
        StrongholdDbContext db,
        ICurrentUserService currentUser,
        IEmailPublisher emailPublisher,
        IConfiguration configuration,
        ILogger<OrderService> logger,
        ActivityLogInterceptor activityLogInterceptor) : base(db)
    {
        _currentUser = currentUser;
        _emailPublisher = emailPublisher;
        _logger = logger;
        _activityLogInterceptor = activityLogInterceptor;
        // environment varijable se citaju jednom u konstruktoru
        var secretKey = configuration["STRIPE_SECRET_KEY"]
            ?? throw new InvalidOperationException("Environment varijabla STRIPE_SECRET_KEY nije postavljena.");
        _publishableKey = configuration["STRIPE_PUBLISHABLE_KEY"]
            ?? throw new InvalidOperationException("Environment varijabla STRIPE_PUBLISHABLE_KEY nije postavljena.");
        _stripe = new StripeClient(secretKey);
    }

    protected override IQueryable<Order> ApplyFilter(IQueryable<Order> query, OrderSearch search)
    {
        if (search.Status.HasValue)
        {
            query = query.Where(o => o.Status == search.Status);
        }
        if (!string.IsNullOrWhiteSpace(search.Text))
        {
            var text = search.Text.Trim();
            query = query.Where(o =>
                o.User.FirstName.Contains(text) ||
                o.User.LastName.Contains(text) ||
                o.User.Username.Contains(text));
        }
        if (search.From.HasValue)
        {
            query = query.Where(o => o.CreatedAt >= search.From);
        }
        if (search.To.HasValue)
        {
            query = query.Where(o => o.CreatedAt <= search.To);
        }
        return query.OrderByDescending(o => o.CreatedAt);
    }

    public async Task<PaymentIntentResponse> CreatePaymentIntentAsync(CreatePaymentIntentRequest request)
    {
        var userId = _currentUser.UserId;
        var user = await Db.Users.FindAsync(userId)
            ?? throw new NotFoundException("Korisnik ne postoji.");

        if (!await Db.Cities.AnyAsync(c => c.Id == request.DeliveryCityId))
        {
            throw new BusinessException("Odabrani grad dostave ne postoji.");
        }

        // korpa na serveru je izvor istine - klijent ne salje stavke
        var cartItems = await Db.CartItems.AsNoTracking()
            .Where(ci => ci.UserId == userId)
            .OrderBy(ci => ci.AddedAt)
            .Select(ci => new OrderItemRequest
            {
                SupplementId = ci.SupplementId,
                Quantity = ci.Quantity
            })
            .ToListAsync();
        if (cartItems.Count == 0)
        {
            throw new BusinessException("Korpa je prazna.");
        }

        var lines = await BuildOrderLinesAsync(cartItems);
        var total = lines.Sum(l => l.Supplement.Price * l.Quantity);

        // adresa dostave se automatski sprema na profil ako korisnik nema adresu
        if (string.IsNullOrWhiteSpace(user.StreetAddress))
        {
            user.StreetAddress = request.DeliveryStreet;
            user.CityId = request.DeliveryCityId;
            await Db.SaveChangesAsync();
        }

        // stavke idu u metadata - confirm ih cita sa Stripe-a, klijentu se ne vjeruje
        var itemsMetadata = string.Join(",", lines.Select(l => $"{l.Supplement.Id}:{l.Quantity}"));
        var intentService = new PaymentIntentService(_stripe);
        var intent = await intentService.CreateAsync(new PaymentIntentCreateOptions
        {
            Amount = (long)(total * 100),
            Currency = Currency,
            AutomaticPaymentMethods = new PaymentIntentAutomaticPaymentMethodsOptions
            {
                Enabled = true,
                AllowRedirects = "never"
            },
            Metadata = new Dictionary<string, string>
            {
                ["userId"] = userId.ToString(),
                ["items"] = itemsMetadata,
                ["deliveryStreet"] = request.DeliveryStreet,
                ["deliveryCityId"] = request.DeliveryCityId.ToString()
            }
        });

        return new PaymentIntentResponse
        {
            PaymentIntentId = intent.Id,
            ClientSecret = intent.ClientSecret,
            Amount = total,
            PublishableKey = _publishableKey
        };
    }

    public async Task<OrderResponse> ConfirmAsync(ConfirmOrderRequest request)
    {
        // idempotentnost: narudzba za ovaj PaymentIntent vec postoji -> vrati je bez novih efekata
        var existing = await Db.Orders
            .Where(o => o.StripePaymentIntentId == request.PaymentIntentId)
            .Select(o => o.Id)
            .FirstOrDefaultAsync();
        if (existing != 0)
        {
            return await GetByIdAsync(existing);
        }

        var intentService = new PaymentIntentService(_stripe);
        PaymentIntent intent;
        try
        {
            intent = await intentService.GetAsync(request.PaymentIntentId);
        }
        catch (StripeException)
        {
            throw new BusinessException("Plaćanje nije pronađeno kod procesora. Pokušajte ponovo.");
        }

        // placanje se finalizira na serveru - klijent nikad ne evidentira uspjeh
        if (intent.Status != "succeeded")
        {
            throw new BusinessException("Plaćanje nije uspješno završeno. Narudžba nije kreirana.");
        }

        var userId = _currentUser.UserId;
        if (!intent.Metadata.TryGetValue("userId", out var intentUserId) ||
            intentUserId != userId.ToString())
        {
            throw new BusinessException("Plaćanje ne pripada prijavljenom korisniku.");
        }

        var items = ParseItemsMetadata(intent.Metadata["items"]);
        var lines = await BuildOrderLinesAsync(items);

        // promjena zaliha je dio poslovne operacije, ne CRUD - ne ide u nedavne aktivnosti/undo
        using var suppression = _activityLogInterceptor.Suppress();
        await using var transaction = await Db.Database.BeginTransactionAsync();

        var order = new Order
        {
            UserId = userId,
            CreatedAt = DateTime.UtcNow,
            Status = OrderStatus.Processing,
            StripePaymentIntentId = intent.Id,
            DeliveryStreet = intent.Metadata["deliveryStreet"],
            DeliveryCityId = int.Parse(intent.Metadata["deliveryCityId"])
        };
        foreach (var line in lines)
        {
            order.Items.Add(new OrderItem
            {
                SupplementId = line.Supplement.Id,
                Quantity = line.Quantity,
                UnitPrice = line.Supplement.Price
            });
            line.Supplement.StockQuantity -= line.Quantity;
        }
        order.TotalAmount = order.Items.Sum(i => i.UnitPrice * i.Quantity);

        Db.Orders.Add(order);
        Db.Notifications.Add(new Notification
        {
            UserId = userId,
            Title = "Plaćanje uspješno",
            Message = $"Vaša narudžba od {order.TotalAmount:F2} KM je plaćena i u obradi je.",
            Type = NotificationType.PaymentConfirmed,
            CreatedAt = DateTime.UtcNow
        });
        // uspjesno placanje prazni korpu - u istoj transakciji kao narudzba
        await Db.CartItems.Where(ci => ci.UserId == userId).ExecuteDeleteAsync();
        await Db.SaveChangesAsync();
        await transaction.CommitAsync();

        var buyer = await Db.Users.FindAsync(userId);
        if (buyer != null)
        {
            _emailPublisher.Publish(new EmailMessage
            {
                To = buyer.Email,
                Subject = "Stronghold - narudžba zaprimljena",
                Body = $"Poštovani {buyer.FirstName},\n\nvaša narudžba #{order.Id} u iznosu od " +
                       $"{order.TotalAmount:F2} KM je uspješno plaćena i u obradi je.\n\nVaš Stronghold"
            });
        }

        _logger.LogInformation("Narudzba {OrderId} kreirana nakon potvrde placanja {IntentId}.",
            order.Id, intent.Id);
        return await GetByIdAsync(order.Id);
    }

    public async Task<PagedResult<OrderResponse>> GetMineAsync(BaseSearchObject search)
    {
        var userId = _currentUser.UserId;
        var query = Db.Orders.AsNoTracking()
            .Where(o => o.UserId == userId)
            .OrderByDescending(o => o.CreatedAt);

        var totalCount = await query.CountAsync();
        var items = await query
            .Skip((search.Page - 1) * search.PageSize)
            .Take(search.PageSize)
            .ProjectToType<OrderResponse>()
            .ToListAsync();
        return new PagedResult<OrderResponse> { Items = items, TotalCount = totalCount };
    }

    public async Task<OrderResponse> ShipAsync(int id)
    {
        var order = await GetEntityAsync(id);
        EnsureStatus(order, OrderStatus.Processing, "poslati");

        order.Status = OrderStatus.Shipped;
        order.StatusChangedAt = DateTime.UtcNow;
        order.StatusChangedByUserId = _currentUser.UserId;
        Db.Notifications.Add(new Notification
        {
            UserId = order.UserId,
            Title = "Narudžba poslana",
            Message = $"Vaša narudžba #{order.Id} je poslana i uskoro stiže na vašu adresu.",
            Type = NotificationType.OrderStatusChanged,
            CreatedAt = DateTime.UtcNow
        });
        await Db.SaveChangesAsync();

        await PublishOrderStatusEmailAsync(order,
            "Stronghold - narudžba poslana",
            $"vaša narudžba #{order.Id} je poslana i uskoro stiže na vašu adresu.");

        _logger.LogInformation("Narudzba {OrderId} oznacena kao poslana.", id);
        return await GetByIdAsync(id);
    }

    public async Task<OrderResponse> DeliverAsync(int id)
    {
        var order = await GetEntityAsync(id);
        EnsureStatus(order, OrderStatus.Shipped, "isporučiti");

        order.Status = OrderStatus.Delivered;
        order.StatusChangedAt = DateTime.UtcNow;
        order.StatusChangedByUserId = _currentUser.UserId;
        Db.Notifications.Add(new Notification
        {
            UserId = order.UserId,
            Title = "Narudžba dostavljena",
            Message = $"Vaša narudžba #{order.Id} je dostavljena. Prijatno korištenje!",
            Type = NotificationType.OrderStatusChanged,
            CreatedAt = DateTime.UtcNow
        });
        await Db.SaveChangesAsync();

        await PublishOrderStatusEmailAsync(order,
            "Stronghold - narudžba dostavljena",
            $"vaša narudžba #{order.Id} je dostavljena. Prijatno korištenje!");

        _logger.LogInformation("Narudzba {OrderId} oznacena kao dostavljena.", id);
        return await GetByIdAsync(id);
    }

    private async Task PublishOrderStatusEmailAsync(Order order, string subject, string message)
    {
        var user = await Db.Users.FindAsync(order.UserId);
        if (user == null)
        {
            return;
        }
        _emailPublisher.Publish(new EmailMessage
        {
            To = user.Email,
            Subject = subject,
            Body = $"Poštovani {user.FirstName},\n\n{message}\n\nVaš Stronghold"
        });
    }

    public async Task<OrderResponse> CancelAsync(int id, OrderCancelRequest request)
    {
        var order = await Db.Orders
            .Include(o => o.Items)
            .FirstOrDefaultAsync(o => o.Id == id)
            ?? throw new NotFoundException("Narudžba ne postoji.");

        if (order.Status != OrderStatus.Processing && order.Status != OrderStatus.Shipped)
        {
            throw new BusinessException($"Narudžba u statusu '{order.Status}' se ne može otkazati.");
        }

        // kupac otkazuje samo vlastitu narudzbu i samo dok nije poslana; admin i poslanu
        if (!_currentUser.IsAdmin)
        {
            if (order.UserId != _currentUser.UserId)
            {
                throw new BusinessException("Možete otkazati samo vlastite narudžbe.");
            }
            if (order.Status == OrderStatus.Shipped)
            {
                throw new BusinessException("Narudžba je već poslana - otkazivanje više nije moguće.");
            }
        }

        // refund na osnovu STVARNO naplacenog iznosa, ne kalkulisane cijene
        var intentService = new PaymentIntentService(_stripe);
        var refundService = new RefundService(_stripe);
        try
        {
            var intent = await intentService.GetAsync(order.StripePaymentIntentId);
            await refundService.CreateAsync(new RefundCreateOptions
            {
                PaymentIntent = order.StripePaymentIntentId,
                Amount = intent.AmountReceived
            });
        }
        catch (StripeException ex)
        {
            _logger.LogError(ex, "Stripe refund neuspjesan za narudzbu {OrderId}.", id);
            throw new BusinessException("Povrat novca nije uspio - narudžba nije otkazana. Pokušajte ponovo.");
        }

        // otkazivanje vraca zalihe - poslovna operacija, ne CRUD (bez nedavnih aktivnosti/undo)
        using var suppression = _activityLogInterceptor.Suppress();
        var supplementIds = order.Items.Select(i => i.SupplementId).ToList();
        var supplements = await Db.Supplements
            .Where(s => supplementIds.Contains(s.Id))
            .ToDictionaryAsync(s => s.Id);
        foreach (var item in order.Items)
        {
            supplements[item.SupplementId].StockQuantity += item.Quantity;
        }

        order.Status = OrderStatus.Cancelled;
        order.StatusChangedAt = DateTime.UtcNow;
        order.StatusChangedByUserId = _currentUser.UserId;
        order.CancellationReason = request.Reason;
        Db.Notifications.Add(new Notification
        {
            UserId = order.UserId,
            Title = "Narudžba otkazana",
            Message = $"Vaša narudžba #{order.Id} je otkazana ({request.Reason}). " +
                      "Novac je vraćen na vašu karticu.",
            Type = NotificationType.OrderStatusChanged,
            CreatedAt = DateTime.UtcNow
        });
        await Db.SaveChangesAsync();

        await PublishOrderStatusEmailAsync(order,
            "Stronghold - narudžba otkazana",
            $"vaša narudžba #{order.Id} je otkazana (razlog: {request.Reason}). " +
            "Puni iznos je vraćen na vašu karticu.");

        _logger.LogInformation("Narudzba {OrderId} otkazana uz Stripe refund.", id);
        return await GetByIdAsync(id);
    }

    private async Task<List<(Supplement Supplement, int Quantity)>> BuildOrderLinesAsync(
        List<OrderItemRequest> items)
    {
        // spajanje duplih stavki iste vrste
        var grouped = items
            .GroupBy(i => i.SupplementId)
            .Select(g => new { SupplementId = g.Key, Quantity = g.Sum(i => i.Quantity) })
            .ToList();

        var ids = grouped.Select(g => g.SupplementId).ToList();
        var supplements = await Db.Supplements
            .Where(s => ids.Contains(s.Id))
            .ToDictionaryAsync(s => s.Id);

        var lines = new List<(Supplement, int)>();
        foreach (var item in grouped)
        {
            if (!supplements.TryGetValue(item.SupplementId, out var supplement))
            {
                throw new BusinessException("Jedan od suplemenata iz korpe više ne postoji.");
            }
            if (supplement.StockQuantity < item.Quantity)
            {
                throw new BusinessException(
                    $"Nema dovoljno zaliha za '{supplement.Name}' (dostupno: {supplement.StockQuantity}).");
            }
            lines.Add((supplement, item.Quantity));
        }
        return lines;
    }

    private static List<OrderItemRequest> ParseItemsMetadata(string metadata)
    {
        return metadata.Split(',')
            .Select(pair => pair.Split(':'))
            .Select(parts => new OrderItemRequest
            {
                SupplementId = int.Parse(parts[0]),
                Quantity = int.Parse(parts[1])
            })
            .ToList();
    }

    private async Task<Order> GetEntityAsync(int id)
    {
        return await Db.Orders.FindAsync(id)
            ?? throw new NotFoundException("Narudžba ne postoji.");
    }

    private static void EnsureStatus(Order order, OrderStatus required, string action)
    {
        if (order.Status != required)
        {
            throw new BusinessException($"Narudžba u statusu '{order.Status}' se ne može {action}.");
        }
    }
}
