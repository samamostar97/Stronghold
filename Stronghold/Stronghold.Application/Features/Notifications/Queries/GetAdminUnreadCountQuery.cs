using MediatR;
using Stronghold.Application.IRepositories;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Notifications.Queries;

public class GetAdminUnreadCountQuery : IRequest<int>, IAuthorizeAdminRequest
{
}

public class GetAdminUnreadCountQueryHandler : IRequestHandler<GetAdminUnreadCountQuery, int>
{
    private readonly INotificationRepository _notificationRepository;

    public GetAdminUnreadCountQueryHandler(
        INotificationRepository notificationRepository)
    {
        _notificationRepository = notificationRepository;
    }

public async Task<int> Handle(GetAdminUnreadCountQuery request, CancellationToken cancellationToken)
    {
        return await _notificationRepository.GetAdminUnreadCountAsync(cancellationToken);
    }
    }