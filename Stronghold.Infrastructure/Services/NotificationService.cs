using Mapster;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Notifications;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Interfaces;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Services;

public class NotificationService : INotificationService
{
    private readonly StrongholdDbContext _db;
    private readonly ICurrentUserService _currentUser;

    public NotificationService(StrongholdDbContext db, ICurrentUserService currentUser)
    {
        _db = db;
        _currentUser = currentUser;
    }

    public async Task<PagedResult<NotificationResponse>> GetMineAsync(BaseSearchObject search)
    {
        var userId = _currentUser.UserId;
        var query = _db.Notifications.AsNoTracking()
            .Where(n => n.UserId == userId)
            .OrderByDescending(n => n.CreatedAt);

        var totalCount = await query.CountAsync();
        var items = await query
            .Skip((search.Page - 1) * search.PageSize)
            .Take(search.PageSize)
            .ProjectToType<NotificationResponse>()
            .ToListAsync();
        return new PagedResult<NotificationResponse> { Items = items, TotalCount = totalCount };
    }

    public async Task<int> GetUnreadCountAsync()
    {
        var userId = _currentUser.UserId;
        return await _db.Notifications.CountAsync(n => n.UserId == userId && !n.IsRead);
    }

    public async Task MarkReadAsync(int id)
    {
        var userId = _currentUser.UserId;
        var notification = await _db.Notifications
            .FirstOrDefaultAsync(n => n.Id == id && n.UserId == userId)
            ?? throw new NotFoundException("Notifikacija ne postoji.");

        notification.IsRead = true;
        await _db.SaveChangesAsync();
    }

    public async Task MarkAllReadAsync()
    {
        var userId = _currentUser.UserId;
        await _db.Notifications
            .Where(n => n.UserId == userId && !n.IsRead)
            .ExecuteUpdateAsync(setters => setters.SetProperty(n => n.IsRead, true));
    }
}
