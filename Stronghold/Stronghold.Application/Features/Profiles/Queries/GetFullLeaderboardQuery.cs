using MediatR;
using Stronghold.Application.Features.Profiles.DTOs;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Profiles.Queries;

public class GetFullLeaderboardQuery : IRequest<IReadOnlyList<LeaderboardEntryResponse>>, IAuthorizeAdminRequest
{
}

public class GetFullLeaderboardQueryHandler : IRequestHandler<GetFullLeaderboardQuery, IReadOnlyList<LeaderboardEntryResponse>>
{
    private readonly IUserProfileService _userProfileService;

    public GetFullLeaderboardQueryHandler(
        IUserProfileService userProfileService)
    {
        _userProfileService = userProfileService;
    }

public async Task<IReadOnlyList<LeaderboardEntryResponse>> Handle(GetFullLeaderboardQuery request, CancellationToken cancellationToken)
    {
        var leaderboard = await _userProfileService.GetFullLeaderboardAsync();
        return leaderboard;
    }
    }