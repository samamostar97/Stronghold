using MediatR;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Notifications.Commands;

public class MarkAllAdminNotificationsAsReadCommand : IRequest<Unit>
{
}

public class MarkAllAdminNotificationsAsReadCommandHandler : IRequestHandler<MarkAllAdminNotificationsAsReadCommand, Unit>
{
    private readonly INotificationRepository _notificationRepository;
    private readonly ICurrentUserService _currentUserService;

    public MarkAllAdminNotificationsAsReadCommandHandler(
        INotificationRepository notificationRepository,
        ICurrentUserService currentUserService)
    {
        _notificationRepository = notificationRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(MarkAllAdminNotificationsAsReadCommand request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();
        await _notificationRepository.MarkAllAdminAsReadAsync(cancellationToken);
        return Unit.Value;
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
}
