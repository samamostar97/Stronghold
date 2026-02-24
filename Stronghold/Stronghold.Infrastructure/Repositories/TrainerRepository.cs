using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Trainers.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Repositories;

public class TrainerRepository : ITrainerRepository
{
    private readonly StrongholdDbContext _context;

    public TrainerRepository(StrongholdDbContext context)
    {
        _context = context;
    }

    public async Task<PagedResult<Trainer>> GetPagedAsync(TrainerFilter filter, CancellationToken cancellationToken = default)
    {
        filter ??= new TrainerFilter();

        var query = _context.Trainers
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

        return new PagedResult<Trainer>
        {
            Items = items,
            TotalCount = totalCount,
            PageNumber = filter.PageNumber
        };
    }

    public Task<Trainer?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        return _context.Trainers
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == id && !x.IsDeleted, cancellationToken);
    }

    public Task<bool> ExistsByEmailAsync(string email, int? excludeId = null, CancellationToken cancellationToken = default)
    {
        var normalized = email.Trim().ToLower();
        return _context.Trainers.AnyAsync(
            x => !x.IsDeleted &&
                 x.Email.ToLower() == normalized &&
                 (!excludeId.HasValue || x.Id != excludeId.Value),
            cancellationToken);
    }

    public Task<bool> ExistsByPhoneAsync(string phoneNumber, int? excludeId = null, CancellationToken cancellationToken = default)
    {
        var normalized = phoneNumber.Trim();
        return _context.Trainers.AnyAsync(
            x => !x.IsDeleted &&
                 x.PhoneNumber == normalized &&
                 (!excludeId.HasValue || x.Id != excludeId.Value),
            cancellationToken);
    }

    public Task<bool> HasAppointmentsAsync(int trainerId, CancellationToken cancellationToken = default)
    {
        return _context.Appointments.AnyAsync(
            x => x.TrainerId == trainerId && !x.IsDeleted,
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
        int trainerId,
        DateTime slotStart,
        DateTime slotEnd,
        CancellationToken cancellationToken = default)
    {
        return _context.Appointments.AnyAsync(
            x => !x.IsDeleted &&
                 x.TrainerId == trainerId &&
                 x.AppointmentDate < slotEnd &&
                 x.AppointmentDate.AddHours(1) > slotStart,
            cancellationToken);
    }

    public async Task<IReadOnlyList<DateTime>> GetAppointmentTimesForDateAsync(
        int trainerId,
        DateTime date,
        CancellationToken cancellationToken = default)
    {
        return await _context.Appointments
            .Where(x => !x.IsDeleted && x.TrainerId == trainerId && x.AppointmentDate.Date == date.Date)
            .Select(x => x.AppointmentDate)
            .ToListAsync(cancellationToken);
    }

    public async Task AddAppointmentAsync(Appointment appointment, CancellationToken cancellationToken = default)
    {
        await _context.Appointments.AddAsync(appointment, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task AddAsync(Trainer entity, CancellationToken cancellationToken = default)
    {
        await _context.Trainers.AddAsync(entity, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task UpdateAsync(Trainer entity, CancellationToken cancellationToken = default)
    {
        _context.Trainers.Update(entity);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteAsync(Trainer entity, CancellationToken cancellationToken = default)
    {
        entity.IsDeleted = true;
        _context.Trainers.Update(entity);
        await _context.SaveChangesAsync(cancellationToken);
    }
}
