using Stronghold.Application.Common;
using Stronghold.Application.DTOs.ActivityLogs;

namespace Stronghold.Application.Interfaces;

public interface IActivityLogService
{
    Task<PagedResult<ActivityLogResponse>> GetPagedAsync(BaseSearchObject search);

    /// <summary>
    /// Ponistava akciju u roku od 1h: undo Create = brisanje, undo Update = vracanje
    /// starih vrijednosti iz snapshota, undo Delete = ponovni unos.
    /// </summary>
    Task UndoAsync(int id);
}
