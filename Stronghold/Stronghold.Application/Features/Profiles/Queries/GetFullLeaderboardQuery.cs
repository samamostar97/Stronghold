using MediatR;
using Stronghold.Application.Features.Profiles.DTOs;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Profiles.Queries;

public class GetFullLeaderboardQuery : IRequest<IReadOnlyList<LeaderboardEntryResponse>>
{
}

public class GetFullLeaderboardQueryHandler : IRequestHandler<GetFullLeaderboardQuery, IReadOnlyList<LeaderboardEntryResponse>>
{
    private readonly IUserProfileService _userProfileService;
    private readonly ICurrentUserService _currentUserService;

    public GetFullLeaderboardQueryHandler(
        IUserProfileService userProfileService,
        ICurrentUserService currentUserService)
    {
        _userProfileService = userProfileService;
        _currentUserService = currentUserService;
    }

    public async Task<IReadOnlyList<LeaderboardEntryResponse>> Handle(GetFullLeaderboardQuery request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();
        var leaderboard = await _userProfileService.GetFullLeaderboardAsync();
        return leaderboard;
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
