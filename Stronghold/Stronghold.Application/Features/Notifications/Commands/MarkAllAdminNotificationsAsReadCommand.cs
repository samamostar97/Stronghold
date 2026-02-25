using MediatR;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Notifications.Commands;

public class MarkAllAdminNotificationsAsReadCommand : IRequest<Unit>, IAuthorizeAdminRequest
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
        await _notificationRepository.MarkAllAdminAsReadAsync(cancellationToken);
        return Unit.Value;
    }
    }