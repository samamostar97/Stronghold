using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Orders.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Orders.Commands;

public class CreateCheckoutPaymentIntentCommand : IRequest<CheckoutResponse>
{
    public List<CheckoutItem> Items { get; set; } = new();
}

public class CheckoutItem
{
    public int SupplementId { get; set; }
    public int Quantity { get; set; }
}

public class CreateCheckoutPaymentIntentCommandHandler
    : IRequestHandler<CreateCheckoutPaymentIntentCommand, CheckoutResponse>
{
    private readonly IOrderRepository _orderRepository;
    private readonly ICurrentUserService _currentUserService;
    private readonly IStripePaymentService _stripePaymentService;

    public CreateCheckoutPaymentIntentCommandHandler(
        IOrderRepository orderRepository,
        ICurrentUserService currentUserService,
        IStripePaymentService stripePaymentService)
    {
        _orderRepository = orderRepository;
        _currentUserService = currentUserService;
        _stripePaymentService = stripePaymentService;
    }

    public async Task<CheckoutResponse> Handle(CreateCheckoutPaymentIntentCommand request, CancellationToken cancellationToken)
    {
        var userId = EnsureAuthenticatedAccess();

        if (request.Items.Count == 0)
        {
            throw new InvalidOperationException("Korpa je prazna.");
        }

        var supplementIds = request.Items.Select(x => x.SupplementId).ToList();
        if (supplementIds.Count != supplementIds.Distinct().Count())
        {
            throw new InvalidOperationException("Duplicirane stavke nisu dozvoljene.");
        }

        var supplements = await _orderRepository.GetSupplementsByIdsAsync(supplementIds, cancellationToken);
        if (supplements.Count != supplementIds.Count)
        {
            throw new InvalidOperationException("Jedan ili vise suplementa ne postoji.");
        }

        decimal totalAmount = 0m;
        foreach (var item in request.Items)
        {
            if (item.Quantity <= 0 || item.Quantity > 99)
            {
                throw new InvalidOperationException("Kolicina mora biti izmedju 1 i 99.");
            }

            var supplement = supplements.First(x => x.Id == item.SupplementId);
            totalAmount += supplement.Price * item.Quantity;
        }

        var totalMinorUnits = ToMinorUnits(totalAmount);
        var paymentIntent = await _stripePaymentService.CreatePaymentIntentAsync(
            totalMinorUnits,
            "bam",
            new Dictionary<string, string> { { "userId", userId.ToString() } });

        return new CheckoutResponse
        {
            ClientSecret = paymentIntent.ClientSecret,
            PaymentIntentId = paymentIntent.Id,
            TotalAmount = totalAmount
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
}

public class CreateCheckoutPaymentIntentCommandValidator : AbstractValidator<CreateCheckoutPaymentIntentCommand>
{
    public CreateCheckoutPaymentIntentCommandValidator()
    {
        RuleFor(x => x.Items)
            .NotNull()
            .Must(x => x.Count > 0)
            .WithMessage("Korpa je prazna.");

        RuleFor(x => x.Items)
            .Must(items => items.Select(i => i.SupplementId).Distinct().Count() == items.Count)
            .WithMessage("Duplicirane stavke nisu dozvoljene.")
            .When(x => x.Items is not null && x.Items.Count > 0);

        RuleForEach(x => x.Items).SetValidator(new CheckoutItemValidator());
    }
}

public class CheckoutItemValidator : AbstractValidator<CheckoutItem>
{
    public CheckoutItemValidator()
    {
        RuleFor(x => x.SupplementId).GreaterThan(0);

        RuleFor(x => x.Quantity)
            .GreaterThan(0)
            .LessThanOrEqualTo(99);
    }
}
