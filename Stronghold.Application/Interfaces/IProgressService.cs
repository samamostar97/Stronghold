using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Progress;

namespace Stronghold.Application.Interfaces;

public interface IProgressService
{
    /// <summary>Leaderboard - top lista po XP-u, bez parametra pretrage (opravdan izuzetak).</summary>
    Task<PagedResult<LeaderboardEntryResponse>> GetLeaderboardAsync(BaseSearchObject search);

    /// <summary>Analitika napretka trenutno prijavljenog clana.</summary>
    Task<ProgressResponse> GetMyProgressAsync();
}
