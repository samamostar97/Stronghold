using MediatR;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Notifications.Queries;

public class GetAdminUnreadCountQuery : IRequest<int>, IAuthorizeAdminRequest
{
}

public class GetAdminUnreadCountQueryHandler : IRequestHandler<GetAdminUnreadCountQuery, int>
{
    private readonly INotificationRepository _notificationRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetAdminUnreadCountQueryHandler(
        INotificationRepository notificationRepository,
        ICurrentUserService currentUserService)
    {
        _notificationRepository = notificationRepository;
        _currentUserService = currentUserService;
    }

public async Task<int> Handle(GetAdminUnreadCountQuery request, CancellationToken cancellationToken)
    {
        return await _notificationRepository.GetAdminUnreadCountAsync(cancellationToken);
    }
    }