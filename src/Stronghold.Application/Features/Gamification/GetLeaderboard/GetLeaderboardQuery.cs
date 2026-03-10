using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Gamification.GetLeaderboard;

[AuthorizeRole("Admin")]
[AuthorizeRole("User")]
public class GetLeaderboardQuery : BaseQueryFilter, IRequest<PagedResult<LeaderboardResponse>>
{
}
