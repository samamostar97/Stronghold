using Mapster;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.GymVisits;
using Stronghold.Application.DTOs.Users;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Interfaces;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Services;

public class GymVisitService : BaseService<GymVisit, GymVisitResponse, GymVisitSearch>, IGymVisitService
{
    public GymVisitService(StrongholdDbContext db) : base(db)
    {
    }

    protected override IQueryable<GymVisit> ApplyFilter(IQueryable<GymVisit> query, GymVisitSearch search)
    {
        if (search.UserId.HasValue)
        {
            query = query.Where(v => v.UserId == search.UserId);
        }
        if (search.From.HasValue)
        {
            query = query.Where(v => v.CheckInAt >= search.From);
        }
        if (search.To.HasValue)
        {
            query = query.Where(v => v.CheckInAt <= search.To);
        }
        if (search.OnlyInGym == true)
        {
            query = query.Where(v => v.CheckOutAt == null);
        }
        return query.OrderByDescending(v => v.CheckInAt);
    }

    public async Task<GymVisitResponse> CheckInAsync(CheckInRequest request)
    {
        var user = await Db.Users.FindAsync(request.UserId)
            ?? throw new NotFoundException("Odabrani korisnik ne postoji.");
        if (user.Role != UserRole.GymMember)
        {
            throw new BusinessException("Check-in je moguć samo za članove teretane.");
        }

        var now = DateTime.UtcNow;
        var hasActiveMembership = await Db.Memberships.AnyAsync(m =>
            m.UserId == user.Id && !m.IsRevoked && m.StartDate <= now && m.EndDate > now);
        if (!hasActiveMembership)
        {
            throw new BusinessException("Korisnik nema aktivnu članarinu - check-in nije moguć.");
        }

        if (await Db.GymVisits.AnyAsync(v => v.UserId == user.Id && v.CheckOutAt == null))
        {
            throw new BusinessException("Korisnik je već prijavljen u teretani.");
        }

        var visit = new GymVisit { UserId = user.Id, CheckInAt = now };
        Db.GymVisits.Add(visit);
        await Db.SaveChangesAsync();
        return await GetByIdAsync(visit.Id);
    }

    public async Task<GymVisitResponse> CheckOutAsync(int visitId)
    {
        var visit = await Db.GymVisits.FindAsync(visitId)
            ?? throw new NotFoundException("Posjeta ne postoji.");
        if (visit.CheckOutAt != null)
        {
            throw new BusinessException("Check-out za ovu posjetu je već evidentiran.");
        }

        visit.CheckOutAt = DateTime.UtcNow;
        await Db.SaveChangesAsync();
        return await GetByIdAsync(visitId);
    }

    public async Task<PagedResult<UserResponse>> GetEligibleUsersAsync(UserSearch search)
    {
        var now = DateTime.UtcNow;
        var query = Db.Users.AsNoTracking()
            .Where(u => u.Role == UserRole.GymMember)
            .Where(u => u.Memberships.Any(m => !m.IsRevoked && m.StartDate <= now && m.EndDate > now))
            .Where(u => !u.GymVisits.Any(v => v.CheckOutAt == null));

        if (!string.IsNullOrWhiteSpace(search.Text))
        {
            var text = search.Text.Trim();
            query = query.Where(u =>
                u.FirstName.Contains(text) ||
                u.LastName.Contains(text) ||
                u.Username.Contains(text));
        }

        var ordered = query.OrderBy(u => u.LastName).ThenBy(u => u.FirstName);
        var totalCount = await ordered.CountAsync();
        var items = await ordered
            .Skip((search.Page - 1) * search.PageSize)
            .Take(search.PageSize)
            .ProjectToType<UserResponse>()
            .ToListAsync();

        return new PagedResult<UserResponse> { Items = items, TotalCount = totalCount };
    }
}
