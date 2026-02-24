using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Orders.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;

namespace Stronghold.Application.Features.Orders.Queries;

public class GetMyOrdersQuery : IRequest<PagedResult<UserOrderResponse>>
{
    public OrderFilter Filter { get; set; } = new();
}

public class GetMyOrdersQueryHandler : IRequestHandler<GetMyOrdersQuery, PagedResult<UserOrderResponse>>
{
    private readonly IOrderRepository _orderRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetMyOrdersQueryHandler(IOrderRepository orderRepository, ICurrentUserService currentUserService)
    {
        _orderRepository = orderRepository;
        _currentUserService = currentUserService;
    }

    public async Task<PagedResult<UserOrderResponse>> Handle(GetMyOrdersQuery request, CancellationToken cancellationToken)
    {
        var userId = EnsureAuthenticatedAccess();

        var filter = request.Filter ?? new OrderFilter();
        var page = await _orderRepository.GetUserOrdersPagedAsync(userId, filter, cancellationToken);

        return new PagedResult<UserOrderResponse>
        {
            Items = page.Items.Select(MapToUserOrderResponse).ToList(),
            TotalCount = page.TotalCount,
            PageNumber = page.PageNumber
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

    private static UserOrderResponse MapToUserOrderResponse(Order order)
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
                SupplementName = x.Supplement?.Name ?? string.Empty,
                Quantity = x.Quantity,
                UnitPrice = x.UnitPrice
            }).ToList()
        };
    }
}

public class GetMyOrdersQueryValidator : AbstractValidator<GetMyOrdersQuery>
{
    public GetMyOrdersQueryValidator()
    {
        RuleFor(x => x.Filter).NotNull().WithMessage("{PropertyName} je obavezno.");

        RuleFor(x => x.Filter.PageNumber)
            .GreaterThanOrEqualTo(1).WithMessage("{PropertyName} mora biti vece ili jednako dozvoljenoj vrijednosti.");

        RuleFor(x => x.Filter.PageSize)
            .GreaterThanOrEqualTo(1).WithMessage("{PropertyName} mora biti vece ili jednako dozvoljenoj vrijednosti.")
            .LessThanOrEqualTo(100).WithMessage("{PropertyName} mora biti manje ili jednako dozvoljenoj vrijednosti.");

        RuleFor(x => x.Filter.Search)
            .MaximumLength(200).WithMessage("{PropertyName} ne smije imati vise od 200 karaktera.")
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.Search));

        RuleFor(x => x.Filter.OrderBy)
            .MaximumLength(30).WithMessage("{PropertyName} ne smije imati vise od 30 karaktera.")
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.OrderBy));

        RuleFor(x => x.Filter.OrderBy)
            .Must(BeValidOrderBy)
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.OrderBy))
            .WithMessage("Neispravna vrijednost za sortiranje.");

        RuleFor(x => x.Filter.Status)
            .Must(BeValidStatus)
            .When(x => x.Filter.Status.HasValue)
            .WithMessage("Neispravna vrijednost statusa.");

        RuleFor(x => x.Filter)
            .Must(HaveValidDateRange)
            .WithMessage("DateFrom mora biti manji ili jednak DateTo.");
    }

    private static bool BeValidOrderBy(string? orderBy)
    {
        var normalized = orderBy?.Trim().ToLowerInvariant();
        return normalized is "date" or "amount" or "status";
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

