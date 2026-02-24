using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Appointments.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Repositories;

public class AppointmentRepository : IAppointmentRepository
{
    private readonly StrongholdDbContext _context;

    public AppointmentRepository(StrongholdDbContext context)
    {
        _context = context;
    }

    public async Task<PagedResult<Appointment>> GetUserUpcomingPagedAsync(
        int userId,
        AppointmentFilter filter,
        CancellationToken cancellationToken = default)
    {
        filter ??= new AppointmentFilter();

        var query = _context.Appointments
            .AsNoTracking()
            .Include(x => x.Trainer)
            .Include(x => x.Nutritionist)
            .Where(x =>
                !x.IsDeleted &&
                x.UserId == userId &&
                x.AppointmentDate > StrongholdTimeUtils.LocalNow);

        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            var search = filter.Search.Trim().ToLower();
            query = query.Where(x =>
                (x.Trainer != null && (x.Trainer.FirstName + " " + x.Trainer.LastName).ToLower().Contains(search)) ||
                (x.Nutritionist != null && (x.Nutritionist.FirstName + " " + x.Nutritionist.LastName).ToLower().Contains(search)));
        }

        query = filter.OrderBy?.Trim().ToLowerInvariant() switch
        {
            "datedesc" => query.OrderByDescending(x => x.AppointmentDate).ThenByDescending(x => x.Id),
            "date" => query.OrderBy(x => x.AppointmentDate).ThenBy(x => x.Id),
            _ => query.OrderBy(x => x.AppointmentDate).ThenBy(x => x.Id)
        };

        var totalCount = await query.CountAsync(cancellationToken);
        var items = await query
            .Skip((filter.PageNumber - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .ToListAsync(cancellationToken);

        return new PagedResult<Appointment>
        {
            Items = items,
            TotalCount = totalCount,
            PageNumber = filter.PageNumber
        };
    }

    public async Task<PagedResult<Appointment>> GetAdminPagedAsync(
        AppointmentFilter filter,
        CancellationToken cancellationToken = default)
    {
        filter ??= new AppointmentFilter();

        var query = _context.Appointments
            .AsNoTracking()
            .Include(x => x.User)
            .Include(x => x.Trainer)
            .Include(x => x.Nutritionist)
            .Where(x => !x.IsDeleted)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            var search = filter.Search.Trim().ToLower();
            query = query.Where(x =>
                (x.User.FirstName + " " + x.User.LastName).ToLower().Contains(search) ||
                (x.Trainer != null && (x.Trainer.FirstName + " " + x.Trainer.LastName).ToLower().Contains(search)) ||
                (x.Nutritionist != null && (x.Nutritionist.FirstName + " " + x.Nutritionist.LastName).ToLower().Contains(search)));
        }

        query = filter.OrderBy?.Trim().ToLowerInvariant() switch
        {
            "date" => query.OrderBy(x => x.AppointmentDate).ThenBy(x => x.Id),
            "datedesc" => query.OrderByDescending(x => x.AppointmentDate).ThenByDescending(x => x.Id),
            "user" => query.OrderBy(x => x.User.FirstName).ThenBy(x => x.User.LastName).ThenBy(x => x.Id),
            "userdesc" => query.OrderByDescending(x => x.User.FirstName).ThenByDescending(x => x.User.LastName).ThenByDescending(x => x.Id),
            _ => query.OrderByDescending(x => x.AppointmentDate).ThenByDescending(x => x.Id)
        };

        var totalCount = await query.CountAsync(cancellationToken);
        var items = await query
            .Skip((filter.PageNumber - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .ToListAsync(cancellationToken);

        return new PagedResult<Appointment>
        {
            Items = items,
            TotalCount = totalCount,
            PageNumber = filter.PageNumber
        };
    }

    public Task<Appointment?> GetByUserAndIdAsync(
        int userId,
        int appointmentId,
        CancellationToken cancellationToken = default)
    {
        return _context.Appointments
            .AsNoTracking()
            .FirstOrDefaultAsync(
                x => !x.IsDeleted && x.UserId == userId && x.Id == appointmentId,
                cancellationToken);
    }

    public Task<Appointment?> GetByIdAsync(int appointmentId, CancellationToken cancellationToken = default)
    {
        return _context.Appointments
            .AsNoTracking()
            .FirstOrDefaultAsync(x => !x.IsDeleted && x.Id == appointmentId, cancellationToken);
    }

    public Task<bool> UserHasAppointmentOnDateAsync(
        int userId,
        DateTime date,
        int? excludeAppointmentId = null,
        CancellationToken cancellationToken = default)
    {
        return _context.Appointments.AnyAsync(
            x => !x.IsDeleted &&
                 x.UserId == userId &&
                 x.AppointmentDate.Date == date.Date &&
                 (!excludeAppointmentId.HasValue || x.Id != excludeAppointmentId.Value),
            cancellationToken);
    }

    public Task<bool> IsTrainerBusyInSlotAsync(
        int trainerId,
        DateTime slotStart,
        DateTime slotEnd,
        int? excludeAppointmentId = null,
        CancellationToken cancellationToken = default)
    {
        return _context.Appointments.AnyAsync(
            x => !x.IsDeleted &&
                 x.TrainerId == trainerId &&
                 (!excludeAppointmentId.HasValue || x.Id != excludeAppointmentId.Value) &&
                 x.AppointmentDate < slotEnd &&
                 x.AppointmentDate.AddHours(1) > slotStart,
            cancellationToken);
    }

    public Task<bool> IsNutritionistBusyInSlotAsync(
        int nutritionistId,
        DateTime slotStart,
        DateTime slotEnd,
        int? excludeAppointmentId = null,
        CancellationToken cancellationToken = default)
    {
        return _context.Appointments.AnyAsync(
            x => !x.IsDeleted &&
                 x.NutritionistId == nutritionistId &&
                 (!excludeAppointmentId.HasValue || x.Id != excludeAppointmentId.Value) &&
                 x.AppointmentDate < slotEnd &&
                 x.AppointmentDate.AddHours(1) > slotStart,
            cancellationToken);
    }

    public Task<bool> TrainerExistsAsync(int trainerId, CancellationToken cancellationToken = default)
    {
        return _context.Trainers.AnyAsync(x => !x.IsDeleted && x.Id == trainerId, cancellationToken);
    }

    public Task<bool> NutritionistExistsAsync(int nutritionistId, CancellationToken cancellationToken = default)
    {
        return _context.Nutritionists.AnyAsync(x => !x.IsDeleted && x.Id == nutritionistId, cancellationToken);
    }

    public Task<bool> UserExistsAsync(int userId, CancellationToken cancellationToken = default)
    {
        return _context.Users.AnyAsync(x => !x.IsDeleted && x.Id == userId, cancellationToken);
    }

    public async Task<bool> TryAddAsync(Appointment appointment, CancellationToken cancellationToken = default)
    {
        try
        {
            await _context.Appointments.AddAsync(appointment, cancellationToken);
            await _context.SaveChangesAsync(cancellationToken);
            return true;
        }
        catch (DbUpdateException)
        {
            return false;
        }
    }

    public async Task<bool> TryUpdateAsync(Appointment appointment, CancellationToken cancellationToken = default)
    {
        try
        {
            _context.Appointments.Update(appointment);
            await _context.SaveChangesAsync(cancellationToken);
            return true;
        }
        catch (DbUpdateException)
        {
            return false;
        }
    }

    public async Task DeleteAsync(Appointment appointment, CancellationToken cancellationToken = default)
    {
        appointment.IsDeleted = true;
        _context.Appointments.Update(appointment);
        await _context.SaveChangesAsync(cancellationToken);
    }
}
