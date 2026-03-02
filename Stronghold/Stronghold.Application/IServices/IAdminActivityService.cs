using Stronghold.Application.Common;
using Stronghold.Application.Features.AdminActivities.DTOs;

namespace Stronghold.Application.IServices;

public interface IAdminActivityService
{
    Task LogAddAsync(int adminUserId, string adminUsername, string entityType, int entityId);
    Task LogDeleteAsync(int adminUserId, string adminUsername, string entityType, int entityId);
    Task<List<AdminActivityResponse>> GetRecentAsync(int count = 20);
    Task<PagedResult<AdminActivityResponse>> GetPagedAsync(AdminActivityFilter filter, CancellationToken cancellationToken = default);
    Task<AdminActivityResponse> UndoAsync(int id, int adminUserId);
}
