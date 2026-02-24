using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Orders.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.Orders.Queries;

public class GetOrderByIdQuery : IRequest<OrderResponse>
{
    public int OrderId { get; set; }
}

public class GetOrderByIdQueryHandler : IRequestHandler<GetOrderByIdQuery, OrderResponse>
{
    private readonly IOrderRepository _orderRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetOrderByIdQueryHandler(IOrderRepository orderRepository, ICurrentUserService currentUserService)
    {
        _orderRepository = orderRepository;
        _currentUserService = currentUserService;
    }

    public async Task<OrderResponse> Handle(GetOrderByIdQuery request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

        var order = await _orderRepository.GetByIdWithDetailsAsync(request.OrderId, cancellationToken);
        if (order is null)
        {
            throw new KeyNotFoundException($"Narudzba sa id '{request.OrderId}' ne postoji.");
        }

        return MapToOrderResponse(order);
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

public class GetOrderByIdQueryValidator : AbstractValidator<GetOrderByIdQuery>
{
    public GetOrderByIdQueryValidator()
    {
        RuleFor(x => x.OrderId).GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
}

