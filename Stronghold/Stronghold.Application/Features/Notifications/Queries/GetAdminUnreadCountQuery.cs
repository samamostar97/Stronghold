using MediatR;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Notifications.Queries;

public class GetAdminUnreadCountQuery : IRequest<int>
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
        EnsureAdminAccess();
        return await _notificationRepository.GetAdminUnreadCountAsync(cancellationToken);
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
