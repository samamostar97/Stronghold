using FluentValidation;
using MediatR;
using Microsoft.Extensions.Logging;
using Stronghold.Application.Features.Orders.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;
using Stronghold.Application.Common;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Orders.Commands;

public class ConfirmOrderCommand : IRequest<UserOrderResponse>, IAuthorizeAuthenticatedRequest
{
    public string PaymentIntentId { get; set; } = string.Empty;
    public List<CheckoutItem> Items { get; set; } = new();
}

public class ConfirmOrderCommandHandler : IRequestHandler<ConfirmOrderCommand, UserOrderResponse>
{
    private readonly IOrderRepository _orderRepository;
    private readonly ICurrentUserService _currentUserService;
    private readonly IStripePaymentService _stripePaymentService;
    private readonly IOrderEmailService _orderEmailService;
    private readonly INotificationService _notificationService;
    private readonly ILogger<ConfirmOrderCommandHandler> _logger;

    public ConfirmOrderCommandHandler(
        IOrderRepository orderRepository,
        ICurrentUserService currentUserService,
        IStripePaymentService stripePaymentService,
        IOrderEmailService orderEmailService,
        INotificationService notificationService,
        ILogger<ConfirmOrderCommandHandler> logger)
    {
        _orderRepository = orderRepository;
        _currentUserService = currentUserService;
        _stripePaymentService = stripePaymentService;
        _orderEmailService = orderEmailService;
        _notificationService = notificationService;
        _logger = logger;
    }

    public async Task<UserOrderResponse> Handle(ConfirmOrderCommand request, CancellationToken cancellationToken)
    {
        var userId = _currentUserService.UserId!.Value;

        // 1. Verify Stripe payment
        var paymentIntent = await _stripePaymentService.VerifyPaymentAsync(request.PaymentIntentId, userId);

        // 2. Idempotency check
        if (await _orderRepository.GetByStripePaymentIdAsync(request.PaymentIntentId, cancellationToken) is not null)
            throw new InvalidOperationException("Narudzba za ovu uplatu vec postoji.");

        // 3. Load & validate supplements
        var supplementIds = request.Items.Select(x => x.SupplementId).ToList();
        var supplements = await _orderRepository.GetSupplementsByIdsAsync(supplementIds, cancellationToken);
        if (supplements.Count != supplementIds.Count)
            throw new InvalidOperationException("Jedan ili vise suplementa ne postoji.");

        // 4. Deduct stock
        var stockItems = request.Items
            .Select(x => (x.SupplementId, x.Quantity))
            .ToList();

        if (!await _orderRepository.DeductStockAsync(stockItems, cancellationToken))
            throw new InvalidOperationException("Nedovoljna kolicina na stanju za jedan ili vise proizvoda.");

        // 5. Build & save order
        var order = BuildOrder(userId, request.Items, supplements, paymentIntent);
        if (!await _orderRepository.TryAddAsync(order, cancellationToken))
        {
            await _orderRepository.RestoreStockAsync(stockItems, cancellationToken);
            throw new InvalidOperationException("Narudzba za ovu uplatu vec postoji.");
        }

        // 6. Side effects (non-critical)
        var user = await _orderRepository.GetUserByIdAsync(userId, cancellationToken);
        await SendNotificationsAsync(userId, user, order);
        await SendLowStockNotificationsAsync(request.Items, supplements);
        if (user is not null)
            await _orderEmailService.SendOrderConfirmationAsync(user, order, order.OrderItems.ToList(), supplements);

        // 7. Map response
        return MapToResponse(order, supplements);
    }

    private static Order BuildOrder(
        int userId,
        List<CheckoutItem> items,
        IReadOnlyList<Supplement> supplements,
        StripePaymentIntentResult paymentIntent)
    {
        var orderItems = new List<OrderItem>();
        decimal totalAmount = 0m;

        foreach (var item in items)
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
            throw new InvalidOperationException("Iznos narudzbe ne odgovara uplati.");

        return new Order
        {
            UserId = userId,
            TotalAmount = ToMajorUnits(totalMinorUnits),
            PurchaseDate = StrongholdTimeUtils.UtcNow,
            Status = OrderStatus.Processing,
            StripePaymentId = paymentIntent.Id,
            OrderItems = orderItems
        };
    }

    private static UserOrderResponse MapToResponse(Order order, IReadOnlyList<Supplement> supplements)
    {
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

    private async Task SendNotificationsAsync(int userId, User? user, Order order)
    {
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
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Slanje admin notifikacije za narudzbu {OrderId} nije uspjelo", order.Id);
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
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Slanje korisnicke notifikacije za narudzbu {OrderId} nije uspjelo", order.Id);
        }
    }

    private async Task SendLowStockNotificationsAsync(
        List<CheckoutItem> items,
        IReadOnlyList<Supplement> supplements)
    {
        const int lowStockThreshold = 5;
        foreach (var item in items)
        {
            var supplement = supplements.First(x => x.Id == item.SupplementId);
            var remaining = supplement.StockQuantity - item.Quantity;
            if (remaining <= lowStockThreshold)
            {
                try
                {
                    await _notificationService.CreateAsync(
                        "low_stock",
                        "Nizak stock",
                        $"Suplement '{supplement.Name}' ima samo {remaining} na stanju.",
                        supplement.Id,
                        "Supplement");
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Low-stock notifikacija za suplement {SupplementId} nije uspjela", supplement.Id);
                }
            }
        }
    }

    private static long ToMinorUnits(decimal amount)
    {
        return (long)Math.Round(amount * 100m, MidpointRounding.AwayFromZero);
    }

    private static decimal ToMajorUnits(long amountMinorUnits)
    {
        return amountMinorUnits / 100m;
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
