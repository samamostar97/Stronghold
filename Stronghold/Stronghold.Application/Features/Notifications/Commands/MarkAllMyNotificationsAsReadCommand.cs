using MediatR;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Notifications.Commands;

public class MarkAllMyNotificationsAsReadCommand : IRequest<Unit>
{
}

public class MarkAllMyNotificationsAsReadCommandHandler : IRequestHandler<MarkAllMyNotificationsAsReadCommand, Unit>
{
    private readonly INotificationRepository _notificationRepository;
    private readonly ICurrentUserService _currentUserService;

    public MarkAllMyNotificationsAsReadCommandHandler(
        INotificationRepository notificationRepository,
        ICurrentUserService currentUserService)
    {
        _notificationRepository = notificationRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(MarkAllMyNotificationsAsReadCommand request, CancellationToken cancellationToken)
    {
        var userId = EnsureAuthenticatedAccess();
        await _notificationRepository.MarkAllUserAsReadAsync(userId, cancellationToken);
        return Unit.Value;
    }

    private int EnsureAuthenticatedAccess()
    {
        if (!_currentUserService.IsAuthenticated || _currentUserService.UserId is null)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }

        return _currentUserService.UserId.Value;
    }
}
