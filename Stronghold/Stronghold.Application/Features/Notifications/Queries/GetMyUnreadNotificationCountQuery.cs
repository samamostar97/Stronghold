using MediatR;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Notifications.Queries;

public class GetMyUnreadNotificationCountQuery : IRequest<int>
{
}

public class GetMyUnreadNotificationCountQueryHandler : IRequestHandler<GetMyUnreadNotificationCountQuery, int>
{
    private readonly INotificationRepository _notificationRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetMyUnreadNotificationCountQueryHandler(
        INotificationRepository notificationRepository,
        ICurrentUserService currentUserService)
    {
        _notificationRepository = notificationRepository;
        _currentUserService = currentUserService;
    }

    public async Task<int> Handle(GetMyUnreadNotificationCountQuery request, CancellationToken cancellationToken)
    {
        var userId = EnsureAuthenticatedAccess();
        return await _notificationRepository.GetUserUnreadCountAsync(userId, cancellationToken);
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
