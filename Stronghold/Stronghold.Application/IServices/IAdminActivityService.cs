using Stronghold.Application.DTOs.Response;

namespace Stronghold.Application.IServices;

public interface IAdminActivityService
{
    Task LogAddAsync(int adminUserId, string adminUsername, string entityType, int entityId);
    Task LogDeleteAsync(int adminUserId, string adminUsername, string entityType, int entityId);
    Task<List<AdminActivityResponse>> GetRecentAsync(int count = 20);
    Task<AdminActivityResponse> UndoAsync(int id, int adminUserId);
}
