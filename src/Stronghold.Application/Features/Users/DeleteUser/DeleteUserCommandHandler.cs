using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Enums;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Users.DeleteUser;

public class DeleteUserCommandHandler : IRequestHandler<DeleteUserCommand, Unit>
{
    private readonly IUserRepository _userRepository;
    private readonly IOrderRepository _orderRepository;
    private readonly IAppointmentRepository _appointmentRepository;
    private readonly IUserMembershipRepository _membershipRepository;
    private readonly ICartItemRepository _cartItemRepository;
    private readonly IWishlistItemRepository _wishlistItemRepository;
    private readonly IAuditService _auditService;
    private readonly ICurrentUserService _currentUserService;

    public DeleteUserCommandHandler(
        IUserRepository userRepository,
        IOrderRepository orderRepository,
        IAppointmentRepository appointmentRepository,
        IUserMembershipRepository membershipRepository,
        ICartItemRepository cartItemRepository,
        IWishlistItemRepository wishlistItemRepository,
        IAuditService auditService,
        ICurrentUserService currentUserService)
    {
        _userRepository = userRepository;
        _orderRepository = orderRepository;
        _appointmentRepository = appointmentRepository;
        _membershipRepository = membershipRepository;
        _cartItemRepository = cartItemRepository;
        _wishlistItemRepository = wishlistItemRepository;
        _auditService = auditService;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(DeleteUserCommand request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByIdAsync(request.Id)
            ?? throw new NotFoundException("Korisnik", request.Id);

        // Soft delete active orders (Pending/Confirmed)
        var activeOrders = await _orderRepository.Query()
            .Where(o => o.UserId == request.Id &&
                (o.Status == OrderStatus.Pending || o.Status == OrderStatus.Confirmed))
            .ToListAsync(cancellationToken);
        foreach (var order in activeOrders)
            _orderRepository.Remove(order);

        // Soft delete active appointments (Pending/Approved)
        var activeAppointments = await _appointmentRepository.Query()
            .Where(a => a.UserId == request.Id &&
                (a.Status == AppointmentStatus.Pending || a.Status == AppointmentStatus.Approved))
            .ToListAsync(cancellationToken);
        foreach (var appointment in activeAppointments)
            _appointmentRepository.Remove(appointment);

        // Deactivate active membership
        var activeMembership = await _membershipRepository.GetActiveByUserIdAsync(request.Id);
        if (activeMembership != null)
        {
            activeMembership.IsActive = false;
            _membershipRepository.Update(activeMembership);
        }

        // Hard delete cart and wishlist
        await _cartItemRepository.ClearCartAsync(request.Id);
        var wishlistItems = await _wishlistItemRepository.GetByUserIdAsync(request.Id);
        foreach (var item in wishlistItems)
            _wishlistItemRepository.HardRemove(item);

        await _auditService.LogDeleteAsync(_currentUserService.UserId, "User", user.Id, user);

        _userRepository.Remove(user);
        await _userRepository.SaveChangesAsync();

        return Unit.Value;
    }
}
