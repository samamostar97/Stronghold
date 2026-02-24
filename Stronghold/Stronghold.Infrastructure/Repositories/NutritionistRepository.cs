using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Nutritionists.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Repositories;

public class NutritionistRepository : INutritionistRepository
{
    private readonly StrongholdDbContext _context;

    public NutritionistRepository(StrongholdDbContext context)
    {
        _context = context;
    }

    public async Task<PagedResult<Nutritionist>> GetPagedAsync(
        NutritionistFilter filter,
        CancellationToken cancellationToken = default)
    {
        filter ??= new NutritionistFilter();

        var query = _context.Nutritionists
            .AsNoTracking()
            .Where(x => !x.IsDeleted)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            var search = filter.Search.Trim().ToLower();
            query = query.Where(x =>
                x.FirstName.ToLower().Contains(search) ||
                x.LastName.ToLower().Contains(search));
        }

        if (!string.IsNullOrWhiteSpace(filter.OrderBy))
        {
            query = filter.OrderBy.Trim().ToLowerInvariant() switch
            {
                "firstname" => query.OrderBy(x => x.FirstName).ThenBy(x => x.Id),
                "firstnamedesc" => query.OrderByDescending(x => x.FirstName).ThenByDescending(x => x.Id),
                "lastname" => query.OrderBy(x => x.LastName).ThenBy(x => x.Id),
                "lastnamedesc" => query.OrderByDescending(x => x.LastName).ThenByDescending(x => x.Id),
                "createdatdesc" => query.OrderByDescending(x => x.CreatedAt).ThenByDescending(x => x.Id),
                "createdat" => query.OrderBy(x => x.CreatedAt).ThenBy(x => x.Id),
                _ => query.OrderBy(x => x.CreatedAt).ThenBy(x => x.Id)
            };
        }
        else
        {
            query = query.OrderBy(x => x.CreatedAt).ThenBy(x => x.Id);
        }

        var totalCount = await query.CountAsync(cancellationToken);
        var items = await query
            .Skip((filter.PageNumber - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .ToListAsync(cancellationToken);

        return new PagedResult<Nutritionist>
        {
            Items = items,
            TotalCount = totalCount,
            PageNumber = filter.PageNumber
        };
    }

    public Task<Nutritionist?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        return _context.Nutritionists
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == id && !x.IsDeleted, cancellationToken);
    }

    public Task<bool> ExistsByEmailAsync(string email, int? excludeId = null, CancellationToken cancellationToken = default)
    {
        var normalized = email.Trim().ToLower();
        return _context.Nutritionists.AnyAsync(
            x => !x.IsDeleted &&
                 x.Email.ToLower() == normalized &&
                 (!excludeId.HasValue || x.Id != excludeId.Value),
            cancellationToken);
    }

    public Task<bool> ExistsByPhoneAsync(
        string phoneNumber,
        int? excludeId = null,
        CancellationToken cancellationToken = default)
    {
        var normalized = phoneNumber.Trim();
        return _context.Nutritionists.AnyAsync(
            x => !x.IsDeleted &&
                 x.PhoneNumber == normalized &&
                 (!excludeId.HasValue || x.Id != excludeId.Value),
            cancellationToken);
    }

    public Task<bool> HasAppointmentsAsync(int nutritionistId, CancellationToken cancellationToken = default)
    {
        return _context.Appointments.AnyAsync(
            x => !x.IsDeleted && x.NutritionistId == nutritionistId,
            cancellationToken);
    }

    public Task<bool> UserHasAppointmentOnDateAsync(int userId, DateTime date, CancellationToken cancellationToken = default)
    {
        return _context.Appointments.AnyAsync(
            x => !x.IsDeleted &&
                 x.UserId == userId &&
                 x.AppointmentDate.Date == date.Date,
            cancellationToken);
    }

    public Task<bool> IsBusyInSlotAsync(
        int nutritionistId,
        DateTime slotStart,
        DateTime slotEnd,
        CancellationToken cancellationToken = default)
    {
        return _context.Appointments.AnyAsync(
            x => !x.IsDeleted &&
                 x.NutritionistId == nutritionistId &&
                 x.AppointmentDate < slotEnd &&
                 x.AppointmentDate.AddHours(1) > slotStart,
            cancellationToken);
    }

    public async Task<IReadOnlyList<DateTime>> GetAppointmentTimesForDateAsync(
        int nutritionistId,
        DateTime date,
        CancellationToken cancellationToken = default)
    {
        return await _context.Appointments
            .Where(x => !x.IsDeleted && x.NutritionistId == nutritionistId && x.AppointmentDate.Date == date.Date)
            .Select(x => x.AppointmentDate)
            .ToListAsync(cancellationToken);
    }

    public async Task AddAppointmentAsync(Appointment appointment, CancellationToken cancellationToken = default)
    {
        await _context.Appointments.AddAsync(appointment, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task AddAsync(Nutritionist entity, CancellationToken cancellationToken = default)
    {
        await _context.Nutritionists.AddAsync(entity, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task UpdateAsync(Nutritionist entity, CancellationToken cancellationToken = default)
    {
        _context.Nutritionists.Update(entity);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteAsync(Nutritionist entity, CancellationToken cancellationToken = default)
    {
        entity.IsDeleted = true;
        _context.Nutritionists.Update(entity);
        await _context.SaveChangesAsync(cancellationToken);
    }
}
