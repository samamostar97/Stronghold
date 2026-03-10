using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Gamification.GetLeaderboard;

public class GetLeaderboardQuery : BaseQueryFilter, IRequest<PagedResult<LeaderboardResponse>>
{
}
