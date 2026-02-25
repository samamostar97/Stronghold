using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Orders.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Orders.Commands;

public class MarkOrderAsDeliveredCommand : IRequest<OrderResponse>, IAuthorizeAdminRequest
{
    public int OrderId { get; set; }
}

public class MarkOrderAsDeliveredCommandHandler : IRequestHandler<MarkOrderAsDeliveredCommand, OrderResponse>
{
    private readonly IOrderRepository _orderRepository;
    private readonly ICurrentUserService _currentUserService;
    private readonly IEmailService _emailService;
    private readonly INotificationService _notificationService;

    public MarkOrderAsDeliveredCommandHandler(
        IOrderRepository orderRepository,
        ICurrentUserService currentUserService,
        IEmailService emailService,
        INotificationService notificationService)
    {
        _orderRepository = orderRepository;
        _currentUserService = currentUserService;
        _emailService = emailService;
        _notificationService = notificationService;
    }

public async Task<OrderResponse> Handle(MarkOrderAsDeliveredCommand request, CancellationToken cancellationToken)
    {
        var order = await _orderRepository.GetByIdWithDetailsAsync(request.OrderId, cancellationToken);
        if (order is null)
        {
            throw new KeyNotFoundException($"Narudzba sa id '{request.OrderId}' ne postoji.");
        }

        if (order.Status == OrderStatus.Delivered)
        {
            throw new InvalidOperationException("Narudzba je vec oznacena kao isporucena.");
        }

        if (order.Status == OrderStatus.Cancelled)
        {
            throw new InvalidOperationException("Otkazana narudzba ne moze biti oznacena kao isporucena.");
        }

        order.Status = OrderStatus.Delivered;
        await _orderRepository.UpdateAsync(order, cancellationToken);

        await SendDeliveryEmailAsync(order);

        try
        {
            await _notificationService.CreateForUserAsync(
                order.UserId,
                "order_delivered",
                "Narudzba isporucena",
                $"Vasa narudzba #{order.Id} je isporucena.",
                order.Id,
                "Order");
        }
        catch
        {
        }

        return MapToOrderResponse(order);
    }

private async Task SendDeliveryEmailAsync(Order order)
    {
        var itemsList = string.Join(
            "",
            order.OrderItems.Select(x => $"<li>{x.Supplement.Name} x{x.Quantity} - {x.UnitPrice:F2} KM</li>"));

        var emailBody = $@"
                <html>
                <body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>
                    <h2 style='color: #2ECC71;'>Vasa narudzba #{order.Id} je na putu</h2>
                    <p>Postovani/a {order.User.FirstName},</p>

                    <div style='background-color: #d4edda; padding: 15px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #2ECC71;'>
                        <p style='margin: 0; font-size: 16px;'>
                            <strong>Vasa dostava je krenula.</strong><br/>
                            Sve je obradjeno i paket je na putu do Vas.
                        </p>
                    </div>

                    <h3>Sadrzaj posiljke:</h3>
                    <ul>{itemsList}</ul>
                    <p><strong>Ukupan iznos: {order.TotalAmount:F2} KM</strong></p>

                    <hr style='border: none; border-top: 1px solid #ddd; margin: 20px 0;'/>
                    <p style='color: #666; font-size: 14px;'>
                        Ocekujte dostavu u narednim danima. Hvala Vam na kupovini.
                    </p>
                    <p>Srdacan pozdrav,<br/><strong>Stronghold Tim</strong></p>
                </body>
                </html>";

        await _emailService.SendEmailAsync(
            order.User.Email,
            $"Narudzba #{order.Id} - dostava je u toku",
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

public class MarkOrderAsDeliveredCommandValidator : AbstractValidator<MarkOrderAsDeliveredCommand>
{
    public MarkOrderAsDeliveredCommandValidator()
    {
        RuleFor(x => x.OrderId).GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
    }