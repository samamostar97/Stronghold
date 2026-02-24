using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Orders.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;

namespace Stronghold.Application.Features.Orders.Commands;

public class ConfirmOrderCommand : IRequest<UserOrderResponse>
{
    public string PaymentIntentId { get; set; } = string.Empty;
    public List<CheckoutItem> Items { get; set; } = new();
}

public class ConfirmOrderCommandHandler : IRequestHandler<ConfirmOrderCommand, UserOrderResponse>
{
    private readonly IOrderRepository _orderRepository;
    private readonly ICurrentUserService _currentUserService;
    private readonly IStripePaymentService _stripePaymentService;
    private readonly IEmailService _emailService;
    private readonly INotificationService _notificationService;

    public ConfirmOrderCommandHandler(
        IOrderRepository orderRepository,
        ICurrentUserService currentUserService,
        IStripePaymentService stripePaymentService,
        IEmailService emailService,
        INotificationService notificationService)
    {
        _orderRepository = orderRepository;
        _currentUserService = currentUserService;
        _stripePaymentService = stripePaymentService;
        _emailService = emailService;
        _notificationService = notificationService;
    }

    public async Task<UserOrderResponse> Handle(ConfirmOrderCommand request, CancellationToken cancellationToken)
    {
        var userId = EnsureAuthenticatedAccess();

        if (request.Items.Count == 0)
        {
            throw new InvalidOperationException("Stavke narudzbe su obavezne.");
        }

        var supplementIds = request.Items.Select(x => x.SupplementId).ToList();
        if (supplementIds.Count != supplementIds.Distinct().Count())
        {
            throw new InvalidOperationException("Duplicirane stavke nisu dozvoljene.");
        }

        foreach (var item in request.Items)
        {
            if (item.Quantity <= 0 || item.Quantity > 99)
            {
                throw new InvalidOperationException("Kolicina mora biti izmedju 1 i 99.");
            }
        }

        var paymentIntent = await _stripePaymentService.GetPaymentIntentAsync(request.PaymentIntentId);
        if (!string.Equals(paymentIntent.Status, "succeeded", StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("Uplata nije uspjela.");
        }

        if (!paymentIntent.Metadata.TryGetValue("userId", out var metadataUserId)
            || metadataUserId != userId.ToString())
        {
            throw new InvalidOperationException("Neovlasteni pristup uplati.");
        }

        var existingOrder = await _orderRepository.GetByStripePaymentIdAsync(request.PaymentIntentId, cancellationToken);
        if (existingOrder is not null)
        {
            throw new InvalidOperationException("Narudzba za ovu uplatu vec postoji.");
        }

        var supplements = await _orderRepository.GetSupplementsByIdsAsync(supplementIds, cancellationToken);
        if (supplements.Count != supplementIds.Count)
        {
            throw new InvalidOperationException("Jedan ili vise suplementa ne postoji.");
        }

        var orderItems = new List<OrderItem>();
        decimal totalAmount = 0m;

        foreach (var item in request.Items)
        {
            var supplement = supplements.First(x => x.Id == item.SupplementId);
            totalAmount += supplement.Price * item.Quantity;

            orderItems.Add(new OrderItem
            {
                SupplementId = item.SupplementId,
                Quantity = item.Quantity,
                UnitPrice = supplement.Price
            });
        }

        var totalMinorUnits = ToMinorUnits(totalAmount);
        if (paymentIntent.Amount != totalMinorUnits)
        {
            throw new InvalidOperationException("Iznos narudzbe ne odgovara uplati.");
        }

        var order = new Order
        {
            UserId = userId,
            TotalAmount = ToMajorUnits(totalMinorUnits),
            PurchaseDate = DateTime.UtcNow,
            Status = OrderStatus.Processing,
            StripePaymentId = request.PaymentIntentId,
            OrderItems = orderItems
        };

        var saved = await _orderRepository.TryAddAsync(order, cancellationToken);
        if (!saved)
        {
            throw new InvalidOperationException("Narudzba za ovu uplatu vec postoji.");
        }

        var user = await _orderRepository.GetUserByIdAsync(userId, cancellationToken);
        if (user is not null)
        {
            await SendPaymentConfirmationEmailAsync(user, order, orderItems, supplements);
        }

        try
        {
            var userName = user is null ? "Korisnik" : $"{user.FirstName} {user.LastName}";
            await _notificationService.CreateAsync(
                "new_order",
                "Nova narudzba",
                $"{userName} je narucio/la za {order.TotalAmount:F2} KM",
                order.Id,
                "Order");
        }
        catch
        {
        }

        try
        {
            await _notificationService.CreateForUserAsync(
                userId,
                "order_confirmed",
                "Narudzba zaprimljena",
                $"Vasa narudzba #{order.Id} ({order.TotalAmount:F2} KM) je zaprimljena i priprema se.",
                order.Id,
                "Order");
        }
        catch
        {
        }

        return new UserOrderResponse
        {
            Id = order.Id,
            TotalAmount = order.TotalAmount,
            PurchaseDate = order.PurchaseDate,
            Status = order.Status,
            CancelledAt = order.CancelledAt,
            CancellationReason = order.CancellationReason,
            OrderItems = order.OrderItems.Select(x => new UserOrderItemResponse
            {
                Id = x.Id,
                SupplementName = supplements.First(s => s.Id == x.SupplementId).Name,
                Quantity = x.Quantity,
                UnitPrice = x.UnitPrice
            }).ToList()
        };
    }

    private int EnsureAuthenticatedAccess()
    {
        if (!_currentUserService.IsAuthenticated || _currentUserService.UserId is null)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }

        return _currentUserService.UserId.Value;
    }

    private static long ToMinorUnits(decimal amount)
    {
        return (long)Math.Round(amount * 100m, MidpointRounding.AwayFromZero);
    }

    private static decimal ToMajorUnits(long amountMinorUnits)
    {
        return amountMinorUnits / 100m;
    }

    private async Task SendPaymentConfirmationEmailAsync(
        User user,
        Order order,
        IReadOnlyList<OrderItem> orderItems,
        IReadOnlyList<Supplement> supplements)
    {
        var itemsList = string.Join(
            "",
            orderItems.Select(x =>
            {
                var supplement = supplements.First(s => s.Id == x.SupplementId);
                return $"<li>{supplement.Name} x{x.Quantity} - {x.UnitPrice:F2} KM</li>";
            }));

        var emailBody = $@"
                <html>
                <body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>
                    <h2 style='color: #e63946;'>Potvrda narudzbe #{order.Id}</h2>
                    <p>Postovani/a {user.FirstName},</p>
                    <p>Vasa uplata je uspjesno primljena. Hvala Vam na povjerenju.</p>

                    <div style='background-color: #f8f9fa; padding: 15px; border-radius: 8px; margin: 20px 0;'>
                        <p style='margin: 0; font-size: 16px;'>
                            <strong>Skladiste je zaprimilo Vasu narudzbu.</strong><br/>
                            Paket se priprema za dostavu.
                        </p>
                    </div>

                    <h3>Detalji narudzbe:</h3>
                    <ul>{itemsList}</ul>
                    <p><strong>Ukupan iznos: {order.TotalAmount:F2} KM</strong></p>
                    <p><strong>Datum narudzbe:</strong> {order.PurchaseDate:dd.MM.yyyy HH:mm}</p>

                    <hr style='border: none; border-top: 1px solid #ddd; margin: 20px 0;'/>
                    <p style='color: #666; font-size: 14px;'>
                        Obavijesticemo Vas kada narudzba bude poslana.
                    </p>
                    <p>Srdacan pozdrav,<br/><strong>Stronghold Tim</strong></p>
                </body>
                </html>";

        await _emailService.SendEmailAsync(
            user.Email,
            $"Potvrda narudzbe #{order.Id} - uplata primljena",
            emailBody);
    }
}

public class ConfirmOrderCommandValidator : AbstractValidator<ConfirmOrderCommand>
{
    public ConfirmOrderCommandValidator()
    {
        RuleFor(x => x.PaymentIntentId)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MaximumLength(255).WithMessage("{PropertyName} ne smije imati vise od 255 karaktera.");

        RuleFor(x => x.Items)
            .NotNull().WithMessage("{PropertyName} je obavezno.")
            .Must(x => x.Count > 0)
            .WithMessage("Stavke narudzbe su obavezne.");

        RuleFor(x => x.Items)
            .Must(items => items.Select(i => i.SupplementId).Distinct().Count() == items.Count)
            .WithMessage("Duplicirane stavke nisu dozvoljene.")
            .When(x => x.Items is not null && x.Items.Count > 0);

        RuleForEach(x => x.Items)
            .SetValidator(new CheckoutItemValidator())
            .WithMessage("Stavke narudzbe sadrze neispravne podatke.");
    }
}

