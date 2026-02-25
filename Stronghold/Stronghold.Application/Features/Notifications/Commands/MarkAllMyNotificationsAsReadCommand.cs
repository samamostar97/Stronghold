using MediatR;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Notifications.Commands;

public class MarkAllMyNotificationsAsReadCommand : IRequest<Unit>, IAuthorizeAuthenticatedRequest
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
        var userId = _currentUserService.UserId!.Value;
        await _notificationRepository.MarkAllUserAsReadAsync(userId, cancellationToken);
        return Unit.Value;
    }
    }