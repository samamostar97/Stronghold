using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Progress;

namespace Stronghold.Application.Interfaces;

public interface IProgressService
{
    // Leaderboard - top lista po XP-u.
    Task<PagedResult<LeaderboardEntryResponse>> GetLeaderboardAsync(BaseSearchObject search);

    // Analitika napretka trenutno prijavljenog clana.
    Task<ProgressResponse> GetMyProgressAsync();
}
