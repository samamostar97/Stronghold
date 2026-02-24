using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Visits.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Repositories;

public class VisitRepository : IVisitRepository
{
    private readonly StrongholdDbContext _context;

    public VisitRepository(StrongholdDbContext context)
    {
        _context = context;
    }

    public async Task<PagedResult<GymVisit>> GetCurrentPagedAsync(VisitFilter filter, CancellationToken cancellationToken = default)
    {
        filter ??= new VisitFilter();

        var query = _context.GymVisits
            .AsNoTracking()
            .Include(x => x.User)
            .Where(x => !x.IsDeleted && x.CheckOutTime == null)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            var search = filter.Search.Trim().ToLower();
            query = query.Where(x =>
                x.User.FirstName.ToLower().Contains(search) ||
                x.User.LastName.ToLower().Contains(search) ||
                x.User.Username.ToLower().Contains(search));
        }

        if (!string.IsNullOrWhiteSpace(filter.OrderBy))
        {
            query = filter.OrderBy.Trim().ToLowerInvariant() switch
            {
                "firstname" => query.OrderBy(x => x.User.FirstName).ThenBy(x => x.Id),
                "lastname" => query.OrderBy(x => x.User.LastName).ThenBy(x => x.Id),
                "username" => query.OrderBy(x => x.User.Username).ThenBy(x => x.Id),
                "checkin" => query.OrderBy(x => x.CheckInTime).ThenBy(x => x.Id),
                "checkindesc" => query.OrderByDescending(x => x.CheckInTime).ThenByDescending(x => x.Id),
                _ => query.OrderByDescending(x => x.CheckInTime).ThenByDescending(x => x.Id)
            };
        }
        else
        {
            query = query.OrderByDescending(x => x.CheckInTime).ThenByDescending(x => x.Id);
        }

        var totalCount = await query.CountAsync(cancellationToken);
        var items = await query
            .Skip((filter.PageNumber - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .ToListAsync(cancellationToken);

        return new PagedResult<GymVisit>
        {
            Items = items,
            TotalCount = totalCount,
            PageNumber = filter.PageNumber
        };
    }

    public Task<User?> GetUserByIdAsync(int userId, CancellationToken cancellationToken = default)
    {
        return _context.Users
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == userId && !x.IsDeleted, cancellationToken);
    }

    public Task<GymVisit?> GetByIdAsync(int visitId, CancellationToken cancellationToken = default)
    {
        return _context.GymVisits
            .FirstOrDefaultAsync(x => x.Id == visitId && !x.IsDeleted, cancellationToken);
    }

    public Task<bool> HasActiveVisitAsync(int userId, CancellationToken cancellationToken = default)
    {
        return _context.GymVisits
            .AnyAsync(x => !x.IsDeleted && x.UserId == userId && x.CheckOutTime == null, cancellationToken);
    }

    public Task<bool> HasActiveMembershipAsync(int userId, DateTime nowUtc, CancellationToken cancellationToken = default)
    {
        return _context.Memberships
            .AnyAsync(x => !x.IsDeleted && x.UserId == userId && x.EndDate > nowUtc, cancellationToken);
    }

    public async Task AddAsync(GymVisit entity, CancellationToken cancellationToken = default)
    {
        await _context.GymVisits.AddAsync(entity, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task UpdateAsync(GymVisit entity, CancellationToken cancellationToken = default)
    {
        _context.GymVisits.Update(entity);
        await _context.SaveChangesAsync(cancellationToken);
    }
}
