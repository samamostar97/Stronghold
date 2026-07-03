using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Notifications;

namespace Stronghold.Application.Interfaces;

/// <summary>Notifikacije trenutno prijavljenog korisnika - id iz JWT tokena.</summary>
public interface INotificationService
{
    Task<PagedResult<NotificationResponse>> GetMineAsync(BaseSearchObject search);
    Task<int> GetUnreadCountAsync();
    Task MarkReadAsync(int id);
    Task MarkAllReadAsync();
}
