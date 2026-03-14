using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;
using Stronghold.Domain.Enums;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Orders.CreateOrder;

public class CreateOrderCommandHandler : IRequestHandler<CreateOrderCommand, OrderResponse>
{
    private readonly IOrderRepository _orderRepository;
    private readonly ICartItemRepository _cartItemRepository;
    private readonly IUserRepository _userRepository;
    private readonly IStripeService _stripeService;
    private readonly ICurrentUserService _currentUserService;

    public CreateOrderCommandHandler(
        IOrderRepository orderRepository,
        ICartItemRepository cartItemRepository,
        IUserRepository userRepository,
        IStripeService stripeService,
        ICurrentUserService currentUserService)
    {
        _orderRepository = orderRepository;
        _cartItemRepository = cartItemRepository;
        _userRepository = userRepository;
        _stripeService = stripeService;
        _currentUserService = currentUserService;
    }

    public async Task<OrderResponse> Handle(CreateOrderCommand request, CancellationToken cancellationToken)
    {
        var userId = _currentUserService.UserId;
        var user = await _userRepository.GetByIdAsync(userId)
            ?? throw new NotFoundException("Korisnik", userId);

        var cartItems = await _cartItemRepository.GetByUserIdAsync(userId);
        if (!cartItems.Any())
            throw new InvalidOperationException("Korpa je prazna.");

        var deliveryAddress = request.DeliveryAddress ?? user.Address;
        if (string.IsNullOrWhiteSpace(deliveryAddress))
            throw new InvalidOperationException("Adresa za dostavu je obavezna.");

        if (string.IsNullOrWhiteSpace(user.Address) && !string.IsNullOrWhiteSpace(request.DeliveryAddress))
        {
            user.Address = request.DeliveryAddress;
            _userRepository.Update(user);
        }

        foreach (var cartItem in cartItems)
        {
            if (cartItem.Product.StockQuantity < cartItem.Quantity)
                throw new InvalidOperationException($"Proizvod '{cartItem.Product.Name}' nema dovoljno na stanju.");
        }

        var totalAmount = cartItems.Sum(ci => ci.Product.Price * ci.Quantity);

        var paymentIntent = await _stripeService.CreatePaymentIntentAsync(totalAmount);

        var order = new Order
        {
            UserId = userId,
            UserFullName = $"{user.FirstName} {user.LastName}",
            TotalAmount = totalAmount,
            DeliveryAddress = deliveryAddress,
            Status = OrderStatus.Pending,
            StripePaymentIntentId = paymentIntent.PaymentIntentId,
            Items = cartItems.Select(ci => new OrderItem
            {
                ProductId = ci.ProductId,
                Quantity = ci.Quantity,
                UnitPrice = ci.Product.Price,
                ProductName = ci.Product.Name,
                ProductImageUrl = ci.Product.ImageUrl
            }).ToList()
        };

        await _orderRepository.AddAsync(order);
        await _cartItemRepository.ClearCartAsync(userId);
        await _orderRepository.SaveChangesAsync();

        order.User = user;
        foreach (var item in order.Items)
        {
            var cartItem = cartItems.First(ci => ci.ProductId == item.ProductId);
            item.Product = cartItem.Product;
        }

        return OrderMappings.ToResponse(order, paymentIntent.ClientSecret);
    }
}
