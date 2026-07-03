using Mapster;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Stripe;
using Stronghold.Application.Common;
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
    private readonly ILogger<OrderService> _logger;
    private readonly StripeClient _stripe;
    private readonly string _publishableKey;

    public OrderService(
        StrongholdDbContext db,
        ICurrentUserService currentUser,
        IConfiguration configuration,
        ILogger<OrderService> logger) : base(db)
    {
        _currentUser = currentUser;
        _logger = logger;
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

        var lines = await BuildOrderLinesAsync(request.Items);
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
        await Db.SaveChangesAsync();
        await transaction.CommitAsync();

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

    public async Task<OrderResponse> DeliverAsync(int id)
    {
        var order = await GetEntityAsync(id);
        EnsureStatus(order, OrderStatus.Processing, "isporučiti");

        order.Status = OrderStatus.Delivered;
        order.StatusChangedAt = DateTime.UtcNow;
        order.StatusChangedByUserId = _currentUser.UserId;
        await Db.SaveChangesAsync();

        // Faza 15: e-mail korisniku preko RabbitMQ - do tada log
        _logger.LogInformation("Narudzba {OrderId} oznacena kao dostavljena.", id);
        return await GetByIdAsync(id);
    }

    public async Task<OrderResponse> CancelAsync(int id, OrderCancelRequest request)
    {
        var order = await Db.Orders
            .Include(o => o.Items)
            .FirstOrDefaultAsync(o => o.Id == id)
            ?? throw new NotFoundException("Narudžba ne postoji.");
        EnsureStatus(order, OrderStatus.Processing, "otkazati");

        // refund na osnovu STVARNO naplacenog iznosa, ne kalkulisane cijene
        var intentService = new PaymentIntentService(_stripe);
        var intent = await intentService.GetAsync(order.StripePaymentIntentId);
        var refundService = new RefundService(_stripe);
        try
        {
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

        // otkazivanje vraca zalihe
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
        await Db.SaveChangesAsync();

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
