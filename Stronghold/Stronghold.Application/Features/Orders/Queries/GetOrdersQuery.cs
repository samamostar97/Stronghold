using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Orders.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;

namespace Stronghold.Application.Features.Orders.Queries;

public class GetOrdersQuery : IRequest<IReadOnlyList<OrderResponse>>
{
    public OrderFilter? Filter { get; set; }
}

public class GetOrdersQueryHandler : IRequestHandler<GetOrdersQuery, IReadOnlyList<OrderResponse>>
{
    private readonly IOrderRepository _orderRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetOrdersQueryHandler(IOrderRepository orderRepository, ICurrentUserService currentUserService)
    {
        _orderRepository = orderRepository;
        _currentUserService = currentUserService;
    }

    public async Task<IReadOnlyList<OrderResponse>> Handle(GetOrdersQuery request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

        var orders = await _orderRepository.GetAllAsync(request.Filter, cancellationToken);
        return orders.Select(MapToOrderResponse).ToList();
    }

    private void EnsureAdminAccess()
    {
        if (!_currentUserService.IsAuthenticated || _currentUserService.UserId is null)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }

        if (!_currentUserService.IsInRole("Admin"))
        {
            throw new UnauthorizedAccessException("Nemate dozvolu za ovu akciju.");
        }
    }

    private static OrderResponse MapToOrderResponse(Order order)
    {
        return new OrderResponse
        {
            Id = order.Id,
            UserId = order.UserId,
            UserFullName = order.User is null ? string.Empty : $"{order.User.FirstName} {order.User.LastName}",
            UserEmail = order.User?.Email ?? string.Empty,
            TotalAmount = order.TotalAmount,
            PurchaseDate = order.PurchaseDate,
            Status = order.Status,
            StripePaymentId = order.StripePaymentId,
            CancelledAt = order.CancelledAt,
            CancellationReason = order.CancellationReason,
            OrderItems = order.OrderItems.Select(x => new OrderItemResponse
            {
                Id = x.Id,
                SupplementId = x.SupplementId,
                SupplementName = x.Supplement?.Name ?? string.Empty,
                Quantity = x.Quantity,
                UnitPrice = x.UnitPrice
            }).ToList()
        };
    }
}

public class GetOrdersQueryValidator : AbstractValidator<GetOrdersQuery>
{
    public GetOrdersQueryValidator()
    {
        When(x => x.Filter is not null, () =>
        {
            RuleFor(x => x.Filter!.Search)
                .MaximumLength(200).WithMessage("{PropertyName} ne smije imati vise od 200 karaktera.")
                .When(x => !string.IsNullOrWhiteSpace(x.Filter!.Search));

            RuleFor(x => x.Filter!.OrderBy)
                .MaximumLength(30).WithMessage("{PropertyName} ne smije imati vise od 30 karaktera.")
                .When(x => !string.IsNullOrWhiteSpace(x.Filter!.OrderBy));

            RuleFor(x => x.Filter!.OrderBy)
                .Must(BeValidOrderBy)
                .When(x => !string.IsNullOrWhiteSpace(x.Filter!.OrderBy))
                .WithMessage("Neispravna vrijednost za sortiranje.");

            RuleFor(x => x.Filter!.PageNumber)
                .GreaterThanOrEqualTo(1).WithMessage("{PropertyName} mora biti vece ili jednako dozvoljenoj vrijednosti.");

            RuleFor(x => x.Filter!.PageSize)
                .GreaterThanOrEqualTo(1).WithMessage("{PropertyName} mora biti vece ili jednako dozvoljenoj vrijednosti.")
                .LessThanOrEqualTo(100).WithMessage("{PropertyName} mora biti manje ili jednako dozvoljenoj vrijednosti.");

            RuleFor(x => x.Filter!.Status)
                .Must(BeValidStatus)
                .When(x => x.Filter!.Status.HasValue)
                .WithMessage("Neispravna vrijednost statusa.");

            RuleFor(x => x.Filter!)
                .Must(HaveValidDateRange)
                .WithMessage("DateFrom mora biti manji ili jednak DateTo.");
        });
    }

    private static bool BeValidOrderBy(string? orderBy)
    {
        var normalized = orderBy?.Trim().ToLowerInvariant();
        return normalized is "date" or "amount" or "status" or "user";
    }

    private static bool BeValidStatus(OrderStatus? status)
    {
        return !status.HasValue || Enum.IsDefined(typeof(OrderStatus), status.Value);
    }

    private static bool HaveValidDateRange(OrderFilter filter)
    {
        return !filter.DateFrom.HasValue ||
               !filter.DateTo.HasValue ||
               filter.DateFrom.Value <= filter.DateTo.Value;
    }
}

