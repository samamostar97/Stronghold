using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Orders.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Orders.Commands;

public class CancelOrderCommand : IRequest<OrderResponse>, IAuthorizeAdminRequest
{
    public int OrderId { get; set; }

public string? Reason { get; set; }
}

public class CancelOrderCommandHandler : IRequestHandler<CancelOrderCommand, OrderResponse>
{
    private readonly IOrderRepository _orderRepository;
    private readonly ICurrentUserService _currentUserService;
    private readonly IStripePaymentService _stripePaymentService;
    private readonly IEmailService _emailService;
    private readonly INotificationService _notificationService;

    public CancelOrderCommandHandler(
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

public async Task<OrderResponse> Handle(CancelOrderCommand request, CancellationToken cancellationToken)
    {
        var order = await _orderRepository.GetByIdWithDetailsAsync(request.OrderId, cancellationToken);
        if (order is null)
        {
            throw new KeyNotFoundException($"Narudzba sa id '{request.OrderId}' ne postoji.");
        }

        if (order.Status == OrderStatus.Cancelled)
        {
            throw new InvalidOperationException("Narudzba je vec otkazana.");
        }

        if (order.Status == OrderStatus.Delivered)
        {
            throw new InvalidOperationException("Isporucena narudzba se ne moze otkazati.");
        }

        if (!string.IsNullOrWhiteSpace(order.StripePaymentId))
        {
            await _stripePaymentService.RefundPaymentIntentAsync(order.StripePaymentId);
        }

        order.Status = OrderStatus.Cancelled;
        order.CancelledAt = DateTime.UtcNow;
        order.CancellationReason = string.IsNullOrWhiteSpace(request.Reason)
            ? null
            : request.Reason.Trim();

        await _orderRepository.UpdateAsync(order, cancellationToken);

        await SendCancellationEmailAsync(order);

        try
        {
            await _notificationService.CreateForUserAsync(
                order.UserId,
                "order_cancelled",
                "Narudzba otkazana",
                $"Vasa narudzba #{order.Id} je otkazana. Refund ce biti procesiran automatski.",
                order.Id,
                "Order");
        }
        catch
        {
        }

        return MapToOrderResponse(order);
    }

private async Task SendCancellationEmailAsync(Order order)
    {
        var itemsList = string.Join(
            "",
            order.OrderItems.Select(x => $"<li>{x.Supplement.Name} x{x.Quantity} - {x.UnitPrice:F2} KM</li>"));

        var reasonText = string.IsNullOrWhiteSpace(order.CancellationReason)
            ? string.Empty
            : $"<p><strong>Razlog:</strong> {order.CancellationReason}</p>";

        var emailBody = $@"
                <html>
                <body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>
                    <h2 style='color: #e63946;'>Narudzba #{order.Id} je otkazana</h2>
                    <p>Postovani/a {order.User.FirstName},</p>

                    <div style='background-color: #f8d7da; padding: 15px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #e63946;'>
                        <p style='margin: 0; font-size: 16px;'>
                            <strong>Vasa narudzba je otkazana.</strong><br/>
                            Ako je uplata izvrsena, refund ce biti procesiran automatski.
                        </p>
                    </div>

                    {reasonText}

                    <h3>Stavke narudzbe:</h3>
                    <ul>{itemsList}</ul>
                    <p><strong>Iznos za refund: {order.TotalAmount:F2} KM</strong></p>

                    <hr style='border: none; border-top: 1px solid #ddd; margin: 20px 0;'/>
                    <p style='color: #666; font-size: 14px;'>
                        Ako imate pitanja, slobodno nas kontaktirajte.
                    </p>
                    <p>Srdacan pozdrav,<br/><strong>Stronghold Tim</strong></p>
                </body>
                </html>";

        await _emailService.SendEmailAsync(
            order.User.Email,
            $"Narudzba #{order.Id} - otkazana",
            emailBody);
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

public class CancelOrderCommandValidator : AbstractValidator<CancelOrderCommand>
{
    public CancelOrderCommandValidator()
    {
        RuleFor(x => x.OrderId).GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");

        RuleFor(x => x.Reason)
            .MaximumLength(500).WithMessage("{PropertyName} ne smije imati vise od 500 karaktera.")
            .When(x => !string.IsNullOrWhiteSpace(x.Reason));
    }
    }