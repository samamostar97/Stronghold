using Stronghold.Application.DTOs.UserProgressDTO;

namespace Stronghold.Application.IServices;

public interface IUserProgressService
{
    Task<UserProgressDTO> GetUserProgressAsync(int userId);
    Task<List<LeaderboardEntryDTO>> GetLeaderboardAsync(int top = 5);
    Task<List<LeaderboardEntryDTO>> GetFullLeaderboardAsync();
}
