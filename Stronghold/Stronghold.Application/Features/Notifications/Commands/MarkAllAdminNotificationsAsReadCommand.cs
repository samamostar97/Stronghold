using MediatR;
using Stronghold.Application.IRepositories;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Notifications.Commands;

public class MarkAllAdminNotificationsAsReadCommand : IRequest<Unit>, IAuthorizeAdminRequest
{
}

public class MarkAllAdminNotificationsAsReadCommandHandler : IRequestHandler<MarkAllAdminNotificationsAsReadCommand, Unit>
{
    private readonly INotificationRepository _notificationRepository;

    public MarkAllAdminNotificationsAsReadCommandHandler(
        INotificationRepository notificationRepository)
    {
        _notificationRepository = notificationRepository;
    }

public async Task<Unit> Handle(MarkAllAdminNotificationsAsReadCommand request, CancellationToken cancellationToken)
    {
        await _notificationRepository.MarkAllAdminAsReadAsync(cancellationToken);
        return Unit.Value;
    }
    }