using Microsoft.EntityFrameworkCore;
using Stripe;
using Stronghold.Application.DTOs.UserDTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Services
{
    public class CheckoutService : ICheckoutService
    {
        private readonly IRepository<Supplement, int> _supplementRepository;
        private readonly IRepository<Order, int> _orderRepository;
        private readonly IRepository<User, int> _userRepository;
        private readonly StrongholdDbContext _context;
        private readonly PaymentIntentService _paymentIntentService;
        private readonly IEmailService _emailService;

        public CheckoutService(
            IRepository<Supplement, int> supplementRepository,
            IRepository<Order, int> orderRepository,
            IRepository<User, int> userRepository,
            StrongholdDbContext context,
            IEmailService emailService)
        {
            _supplementRepository = supplementRepository;
            _orderRepository = orderRepository;
            _userRepository = userRepository;
            _context = context;
            _paymentIntentService = new PaymentIntentService();
            _emailService = emailService;
        }

        public async Task<CheckoutResponseDTO> CreatePaymentIntent(int userId, CheckoutRequestDTO request)
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

            return new CheckoutResponseDTO
            {
                ClientSecret = paymentIntent.ClientSecret,
                PaymentIntentId = paymentIntent.Id,
                TotalAmount = totalAmount
            };
        }

        public async Task<UserOrdersDTO> ConfirmOrder(int userId, ConfirmOrderDTO request)
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
                var existingOrder = await _orderRepository.AsQueryable()
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
                    await _orderRepository.AddAsync(order);
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

                return new UserOrdersDTO
                {
                    Id = order.Id,
                    TotalAmount = order.TotalAmount,
                    PurchaseDate = order.PurchaseDate,
                    Status = order.Status,
                    OrderItems = orderItems.Select(oi => new UserOrderItemsDTO
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
    }
}
