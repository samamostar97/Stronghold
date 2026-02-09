using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Stripe;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Filters;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Services
{
    public class OrderService : IOrderService
    {
        private readonly IRepository<Order, int> _repository;
        private readonly IRepository<Supplement, int> _supplementRepository;
        private readonly IRepository<User, int> _userRepository;
        private readonly StrongholdDbContext _context;
        private readonly IMapper _mapper;
        private readonly IEmailService _emailService;
        private readonly INotificationService _notificationService;
        private readonly PaymentIntentService _paymentIntentService;

        public OrderService(
            IRepository<Order, int> repository,
            IRepository<Supplement, int> supplementRepository,
            IRepository<User, int> userRepository,
            StrongholdDbContext context,
            IMapper mapper,
            IEmailService emailService,
            INotificationService notificationService)
        {
            _repository = repository;
            _supplementRepository = supplementRepository;
            _userRepository = userRepository;
            _context = context;
            _mapper = mapper;
            _emailService = emailService;
            _notificationService = notificationService;
            _paymentIntentService = new PaymentIntentService();
        }

        public async Task<IEnumerable<OrderResponse>> GetAllAsync(OrderQueryFilter? filter)
        {
            var query = _repository.AsQueryable();
            query = ApplyFilter(query, filter);
            var entities = await query.ToListAsync();
            return _mapper.Map<IEnumerable<OrderResponse>>(entities);
        }

        public async Task<PagedResult<OrderResponse>> GetPagedAsync(OrderQueryFilter filter)
        {
            var query = _repository.AsQueryable();
            query = ApplyFilter(query, filter);

            var totalCount = await query.CountAsync();

            var items = await query
                .Skip((filter.PageNumber - 1) * filter.PageSize)
                .Take(filter.PageSize)
                .ToListAsync();

            return new PagedResult<OrderResponse>
            {
                Items = _mapper.Map<List<OrderResponse>>(items),
                TotalCount = totalCount,
                PageNumber = filter.PageNumber,
            };
        }

        public async Task<OrderResponse> GetByIdAsync(int id)
        {
            var query = _repository.AsQueryable()
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Supplement);

            var entity = await query.FirstOrDefaultAsync(o => o.Id == id);
            if (entity == null)
                throw new KeyNotFoundException($"Narudžba sa id '{id}' nije pronađena.");

            return _mapper.Map<OrderResponse>(entity);
        }

        public async Task<OrderResponse> MarkAsDeliveredAsync(int orderId)
        {
            var query = _repository.AsQueryable()
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Supplement);

            var order = await query.FirstOrDefaultAsync(o => o.Id == orderId);
            if (order == null)
                throw new KeyNotFoundException($"Narudžba sa id '{orderId}' nije pronađena.");

            if (order.Status == OrderStatus.Delivered)
                throw new InvalidOperationException("Narudžba je već označena kao isporučena.");

            if (order.Status == OrderStatus.Cancelled)
                throw new InvalidOperationException("Otkazana narudžba ne može biti označena kao isporučena.");

            order.Status = OrderStatus.Delivered;
            await _repository.UpdateAsync(order);

            await SendDeliveryEmailAsync(order);

            return _mapper.Map<OrderResponse>(order);
        }

        public async Task<PagedResult<UserOrderResponse>> GetOrdersByUserIdAsync(int userId, OrderQueryFilter filter)
        {
            var query = _repository.AsQueryable()
                .Where(x => x.UserId == userId)
                .Include(x => x.OrderItems)
                    .ThenInclude(x => x.Supplement)
                .OrderByDescending(x => x.PurchaseDate);

            var totalCount = await query.CountAsync();

            var orders = await query
                .Skip((filter.PageNumber - 1) * filter.PageSize)
                .Take(filter.PageSize)
                .ToListAsync();

            var items = orders.Select(x => new UserOrderResponse
            {
                Id = x.Id,
                TotalAmount = x.TotalAmount,
                PurchaseDate = x.PurchaseDate,
                Status = x.Status,
                OrderItems = x.OrderItems.Select(oi => new UserOrderItemResponse
                {
                    Id = oi.Id,
                    SupplementName = oi.Supplement.Name,
                    Quantity = oi.Quantity,
                    UnitPrice = oi.UnitPrice
                }).ToList()
            }).ToList();

            return new PagedResult<UserOrderResponse>
            {
                Items = items,
                TotalCount = totalCount,
                PageNumber = filter.PageNumber
            };
        }

        public async Task<CheckoutResponse> CreatePaymentIntentAsync(int userId, CheckoutRequest request)
        {
            if (request.Items == null || !request.Items.Any())
                throw new InvalidOperationException("Korpa je prazna.");

            // Validate no duplicate supplement IDs
            var supplementIds = request.Items.Select(i => i.SupplementId).ToList();
            if (supplementIds.Count != supplementIds.Distinct().Count())
                throw new InvalidOperationException("Duplicirane stavke nisu dozvoljene.");

            var supplements = await _supplementRepository.AsQueryable()
                .Where(s => supplementIds.Contains(s.Id))
                .ToListAsync();

            if (supplements.Count != supplementIds.Count)
                throw new InvalidOperationException("Jedan ili vise suplementa ne postoji.");

            decimal totalAmount = 0;
            foreach (var item in request.Items)
            {
                if (item.Quantity <= 0 || item.Quantity > 99)
                    throw new InvalidOperationException("Kolicina mora biti izmedju 1 i 99.");

                var supplement = supplements.First(s => s.Id == item.SupplementId);
                totalAmount += supplement.Price * item.Quantity;
            }

            var options = new PaymentIntentCreateOptions
            {
                Amount = (long)Math.Round(totalAmount * 100m, MidpointRounding.AwayFromZero),
                Currency = "bam",
                Metadata = new Dictionary<string, string>
                {
                    { "userId", userId.ToString() }
                }
            };

            var paymentIntent = await _paymentIntentService.CreateAsync(options);

            return new CheckoutResponse
            {
                ClientSecret = paymentIntent.ClientSecret,
                PaymentIntentId = paymentIntent.Id,
                TotalAmount = totalAmount
            };
        }

        public async Task<UserOrderResponse> ConfirmOrderAsync(int userId, ConfirmOrderRequest request)
        {
            if (request.Items == null || !request.Items.Any())
                throw new InvalidOperationException("Stavke narudzbe su obavezne.");

            // Validate no duplicate supplement IDs
            var supplementIds = request.Items.Select(i => i.SupplementId).ToList();
            if (supplementIds.Count != supplementIds.Distinct().Count())
                throw new InvalidOperationException("Duplicirane stavke nisu dozvoljene.");

            // Validate quantities
            foreach (var item in request.Items)
            {
                if (item.Quantity <= 0 || item.Quantity > 99)
                    throw new InvalidOperationException("Kolicina mora biti izmedju 1 i 99.");
            }

            // Verify payment with Stripe
            var paymentIntent = await _paymentIntentService.GetAsync(request.PaymentIntentId);

            if (paymentIntent.Status != "succeeded")
                throw new InvalidOperationException("Uplata nije uspjela.");

            // Verify PaymentIntent belongs to this user
            if (!paymentIntent.Metadata.TryGetValue("userId", out var metaUserId) ||
                metaUserId != userId.ToString())
                throw new InvalidOperationException("Neovlasteni pristup uplati.");

            var stripeAmountCents = paymentIntent.Amount;

            // Use transaction to prevent race condition on duplicate orders
            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                // Idempotency: check for duplicate order with same StripePaymentId
                var existingOrder = await _repository.AsQueryable()
                    .FirstOrDefaultAsync(o => o.StripePaymentId == request.PaymentIntentId);

                if (existingOrder != null)
                    throw new InvalidOperationException("Narudzba za ovu uplatu vec postoji.");

                // Fetch supplements from DB for server-side price verification
                var supplements = await _supplementRepository.AsQueryable()
                    .Where(s => supplementIds.Contains(s.Id))
                    .ToListAsync();

                if (supplements.Count != supplementIds.Count)
                    throw new InvalidOperationException("Jedan ili vise suplementa ne postoji.");

                // Build order items with server-side prices
                var orderItems = new List<OrderItem>();
                decimal totalAmount = 0;

                foreach (var item in request.Items)
                {
                    var supplement = supplements.First(s => s.Id == item.SupplementId);
                    var unitPrice = supplement.Price;
                    totalAmount += unitPrice * item.Quantity;

                    orderItems.Add(new OrderItem
                    {
                        SupplementId = item.SupplementId,
                        Quantity = item.Quantity,
                        UnitPrice = unitPrice,
                        CreatedAt = DateTime.UtcNow
                    });
                }

                // Verify total matches Stripe amount
                var stripeTotal = stripeAmountCents / 100m;
                if (totalAmount != stripeTotal)
                    throw new InvalidOperationException("Iznos narudzbe ne odgovara uplati.");

                var order = new Order
                {
                    UserId = userId,
                    TotalAmount = totalAmount,
                    PurchaseDate = DateTime.UtcNow,
                    Status = OrderStatus.Processing,
                    StripePaymentId = request.PaymentIntentId,
                    CreatedAt = DateTime.UtcNow,
                    OrderItems = orderItems
                };

                try
                {
                    await _repository.AddAsync(order);
                }
                catch (DbUpdateException)
                {
                    throw new InvalidOperationException("Narudzba za ovu uplatu vec postoji.");
                }

                await transaction.CommitAsync();

                // Send payment confirmation email
                var user = await _userRepository.GetByIdAsync(userId);
                if (user != null)
                {
                    await SendPaymentConfirmationEmailAsync(user, order, orderItems, supplements);
                }

                // Create notification for admin
                try
                {
                    var userName = user != null ? $"{user.FirstName} {user.LastName}" : "Korisnik";
                    await _notificationService.CreateAsync(
                        "new_order",
                        "Nova narudzba",
                        $"{userName} je narucio/la za {order.TotalAmount:F2} KM",
                        order.Id,
                        "Order");
                }
                catch { /* Don't fail order on notification error */ }

                return new UserOrderResponse
                {
                    Id = order.Id,
                    TotalAmount = order.TotalAmount,
                    PurchaseDate = order.PurchaseDate,
                    Status = order.Status,
                    OrderItems = orderItems.Select(oi => new UserOrderItemResponse
                    {
                        Id = oi.Id,
                        SupplementName = supplements.First(s => s.Id == oi.SupplementId).Name,
                        Quantity = oi.Quantity,
                        UnitPrice = oi.UnitPrice
                    }).ToList()
                };
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }
        }

        public async Task<OrderResponse> CancelOrderAsync(int orderId, string? reason)
        {
            var query = _repository.AsQueryable()
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Supplement);

            var order = await query.FirstOrDefaultAsync(o => o.Id == orderId);
            if (order == null)
                throw new KeyNotFoundException($"Narudžba sa id '{orderId}' nije pronađena.");

            if (order.Status == OrderStatus.Cancelled)
                throw new InvalidOperationException("Narudžba je već otkazana.");

            if (order.Status == OrderStatus.Delivered)
                throw new InvalidOperationException("Isporučena narudžba ne može biti otkazana.");

            // Attempt Stripe refund if payment was made
            if (!string.IsNullOrEmpty(order.StripePaymentId))
            {
                try
                {
                    var refundService = new RefundService();
                    await refundService.CreateAsync(new RefundCreateOptions
                    {
                        PaymentIntent = order.StripePaymentId
                    });
                }
                catch (StripeException ex)
                {
                    throw new InvalidOperationException(
                        $"Stripe refund nije uspio: {ex.Message}");
                }
            }

            order.Status = OrderStatus.Cancelled;
            order.CancelledAt = DateTime.UtcNow;
            order.CancellationReason = reason;
            await _repository.UpdateAsync(order);

            await SendCancellationEmailAsync(order, reason);

            // Create notification for admin
            try
            {
                var reasonSuffix = !string.IsNullOrEmpty(reason) ? $": {reason}" : "";
                await _notificationService.CreateAsync(
                    "order_cancelled",
                    "Narudzba otkazana",
                    $"Narudzba #{order.Id} je otkazana{reasonSuffix}",
                    order.Id,
                    "Order");
            }
            catch { /* Don't fail cancellation on notification error */ }

            return _mapper.Map<OrderResponse>(order);
        }

        // =====================
        // Email helpers
        // =====================

        private async Task SendDeliveryEmailAsync(Order order)
        {
            var itemsList = string.Join("", order.OrderItems.Select(oi =>
                $"<li>{oi.Supplement.Name} x{oi.Quantity} — {oi.UnitPrice:F2} KM</li>"));

            var emailBody = $@"
                <html>
                <body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>
                    <h2 style='color: #2ECC71;'>🚚 Vaša narudžba #{order.Id} je na putu!</h2>
                    <p>Poštovani/a {order.User.FirstName},</p>

                    <div style='background-color: #d4edda; padding: 15px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #2ECC71;'>
                        <p style='margin: 0; font-size: 16px;'>
                            <strong>✅ Vaša dostava je krenula!</strong><br/>
                            Sve je prošlo u redu i Vaš paket je na putu do Vas.
                        </p>
                    </div>

                    <h3>Sadržaj pošiljke:</h3>
                    <ul>{itemsList}</ul>
                    <p><strong>Ukupan iznos: {order.TotalAmount:F2} KM</strong></p>

                    <hr style='border: none; border-top: 1px solid #ddd; margin: 20px 0;'/>
                    <p style='color: #666; font-size: 14px;'>
                        Očekujte dostavu u narednim danima. Hvala Vam što kupujete kod nas!
                    </p>
                    <p>Srdačan pozdrav,<br/><strong>Stronghold Tim</strong></p>
                </body>
                </html>";

            await _emailService.SendEmailAsync(
                order.User.Email,
                $"Narudžba #{order.Id} — Vaša dostava je na putu! 🚚",
                emailBody);
        }

        private async Task SendPaymentConfirmationEmailAsync(
            User user,
            Order order,
            List<OrderItem> orderItems,
            List<Supplement> supplements)
        {
            var itemsList = string.Join("", orderItems.Select(oi =>
            {
                var supplement = supplements.First(s => s.Id == oi.SupplementId);
                return $"<li>{supplement.Name} x{oi.Quantity} — {oi.UnitPrice:F2} KM</li>";
            }));

            var emailBody = $@"
                <html>
                <body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>
                    <h2 style='color: #e63946;'>Potvrda narudžbe #{order.Id}</h2>
                    <p>Poštovani/a {user.FirstName},</p>
                    <p>Vaša uplata je uspješno primljena! Hvala Vam na povjerenju.</p>

                    <div style='background-color: #f8f9fa; padding: 15px; border-radius: 8px; margin: 20px 0;'>
                        <p style='margin: 0; font-size: 16px;'>
                            <strong>🏭 Skladište je zaprimilo Vašu narudžbu.</strong><br/>
                            Vaš paket se priprema za dostavu.
                        </p>
                    </div>

                    <h3>Detalji narudžbe:</h3>
                    <ul>{itemsList}</ul>
                    <p><strong>Ukupan iznos: {order.TotalAmount:F2} KM</strong></p>
                    <p><strong>Datum narudžbe:</strong> {order.PurchaseDate:dd.MM.yyyy HH:mm}</p>

                    <hr style='border: none; border-top: 1px solid #ddd; margin: 20px 0;'/>
                    <p style='color: #666; font-size: 14px;'>
                        Obavijestit ćemo Vas čim Vaša narudžba bude poslana.
                    </p>
                    <p>Srdačan pozdrav,<br/><strong>Stronghold Tim</strong></p>
                </body>
                </html>";

            await _emailService.SendEmailAsync(
                user.Email,
                $"Potvrda narudžbe #{order.Id} — Uplata primljena",
                emailBody);
        }

        private async Task SendCancellationEmailAsync(Order order, string? reason)
        {
            var itemsList = string.Join("", order.OrderItems.Select(oi =>
                $"<li>{oi.Supplement.Name} x{oi.Quantity} — {oi.UnitPrice:F2} KM</li>"));

            var reasonText = !string.IsNullOrEmpty(reason)
                ? $"<p><strong>Razlog:</strong> {reason}</p>"
                : "";

            var emailBody = $@"
                <html>
                <body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>
                    <h2 style='color: #e63946;'>Narudžba #{order.Id} je otkazana</h2>
                    <p>Poštovani/a {order.User.FirstName},</p>

                    <div style='background-color: #f8d7da; padding: 15px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #e63946;'>
                        <p style='margin: 0; font-size: 16px;'>
                            <strong>Vaša narudžba je otkazana.</strong><br/>
                            Ukoliko je uplata izvršena, refund će biti procesiran automatski.
                        </p>
                    </div>

                    {reasonText}

                    <h3>Stavke narudžbe:</h3>
                    <ul>{itemsList}</ul>
                    <p><strong>Iznos za refund: {order.TotalAmount:F2} KM</strong></p>

                    <hr style='border: none; border-top: 1px solid #ddd; margin: 20px 0;'/>
                    <p style='color: #666; font-size: 14px;'>
                        Ako imate pitanja, slobodno nas kontaktirajte.
                    </p>
                    <p>Srdačan pozdrav,<br/><strong>Stronghold Tim</strong></p>
                </body>
                </html>";

            await _emailService.SendEmailAsync(
                order.User.Email,
                $"Narudžba #{order.Id} — Otkazana",
                emailBody);
        }

        private IQueryable<Order> ApplyFilter(IQueryable<Order> query, OrderQueryFilter? filter)
        {
            query = query
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Supplement);

            if (filter == null)
                return query.OrderByDescending(o => o.PurchaseDate);

            if (!string.IsNullOrEmpty(filter.Search))
            {
                var search = filter.Search.ToLower();
                query = query.Where(o =>
                    o.User.FirstName.ToLower().Contains(search) ||
                    o.User.LastName.ToLower().Contains(search) ||
                    o.User.Email.ToLower().Contains(search) ||
                    o.Id.ToString().Contains(search));
            }

            if (filter.Status.HasValue)
            {
                query = query.Where(o => o.Status == filter.Status.Value);
            }

            if (filter.DateFrom.HasValue)
            {
                query = query.Where(o => o.PurchaseDate >= filter.DateFrom.Value);
            }

            if (filter.DateTo.HasValue)
            {
                query = query.Where(o => o.PurchaseDate <= filter.DateTo.Value);
            }

            if (!string.IsNullOrEmpty(filter.OrderBy))
            {
                query = filter.OrderBy.ToLower() switch
                {
                    "date" => filter.Descending
                        ? query.OrderByDescending(o => o.PurchaseDate)
                        : query.OrderBy(o => o.PurchaseDate),
                    "amount" => filter.Descending
                        ? query.OrderByDescending(o => o.TotalAmount)
                        : query.OrderBy(o => o.TotalAmount),
                    "status" => filter.Descending
                        ? query.OrderByDescending(o => o.Status)
                        : query.OrderBy(o => o.Status),
                    "user" => filter.Descending
                        ? query.OrderByDescending(o => o.User.LastName)
                        : query.OrderBy(o => o.User.LastName),
                    _ => filter.Descending
                        ? query.OrderByDescending(o => o.PurchaseDate)
                        : query.OrderBy(o => o.PurchaseDate)
                };
            }
            else
            {
                query = filter.Descending
                    ? query.OrderByDescending(o => o.PurchaseDate)
                    : query.OrderBy(o => o.PurchaseDate);
            }

            return query;
        }
    }
}
