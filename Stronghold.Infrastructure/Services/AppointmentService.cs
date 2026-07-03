using Mapster;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Appointments;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Interfaces;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Services;

public class AppointmentService : BaseService<Appointment, AppointmentResponse, AppointmentSearch>,
    IAppointmentService
{
    /// <summary>Centralizovana state machine - jedino mjesto koje definise dozvoljene prelaze.</summary>
    private static readonly Dictionary<AppointmentStatus, AppointmentStatus[]> AllowedTransitions = new()
    {
        [AppointmentStatus.Pending] = new[] { AppointmentStatus.Confirmed, AppointmentStatus.Cancelled },
        [AppointmentStatus.Confirmed] = new[] { AppointmentStatus.Completed, AppointmentStatus.Cancelled },
        [AppointmentStatus.Completed] = Array.Empty<AppointmentStatus>(),
        [AppointmentStatus.Cancelled] = Array.Empty<AppointmentStatus>()
    };

    private readonly ICurrentUserService _currentUser;

    public AppointmentService(StrongholdDbContext db, ICurrentUserService currentUser) : base(db)
    {
        _currentUser = currentUser;
    }

    protected override IQueryable<Appointment> ApplyFilter(IQueryable<Appointment> query, AppointmentSearch search)
    {
        if (search.Date.HasValue)
        {
            query = query.Where(a => a.Date == search.Date);
        }
        if (search.Status.HasValue)
        {
            query = query.Where(a => a.Status == search.Status);
        }
        if (search.StaffMemberId.HasValue)
        {
            query = query.Where(a => a.StaffMemberId == search.StaffMemberId);
        }
        if (!string.IsNullOrWhiteSpace(search.Text))
        {
            var text = search.Text.Trim();
            query = query.Where(a =>
                a.User.FirstName.Contains(text) ||
                a.User.LastName.Contains(text) ||
                a.User.Username.Contains(text));
        }
        return query.OrderByDescending(a => a.Date).ThenByDescending(a => a.StartHour);
    }

    public async Task<List<int>> GetFreeSlotsAsync(int staffMemberId, DateOnly date)
    {
        var staff = await Db.StaffMembers.FindAsync(staffMemberId)
            ?? throw new NotFoundException("Odabrana osoba ne postoji.");

        var takenHours = await Db.Appointments
            .Where(a => a.StaffMemberId == staffMemberId &&
                        a.Date == date &&
                        a.Status != AppointmentStatus.Cancelled)
            .Select(a => a.StartHour)
            .ToListAsync();

        var now = DateTime.UtcNow;
        var today = DateOnly.FromDateTime(now);

        return Enumerable.Range(staff.WorkStartHour, staff.WorkEndHour - staff.WorkStartHour)
            .Where(hour => !takenHours.Contains(hour))
            .Where(hour => date > today || hour > now.Hour)
            .ToList();
    }

    public async Task<AppointmentResponse> CreateMineAsync(AppointmentCreateRequest request)
    {
        return await CreateInternalAsync(_currentUser.UserId, request.StaffMemberId, request.Date, request.StartHour);
    }

    public async Task<PagedResult<AppointmentResponse>> GetMineAsync(BaseSearchObject search)
    {
        var userId = _currentUser.UserId;
        var query = Db.Appointments.AsNoTracking()
            .Where(a => a.UserId == userId)
            .OrderByDescending(a => a.Date).ThenByDescending(a => a.StartHour);

        return await ProjectPageAsync(query, search);
    }

    public async Task<AppointmentResponse> CreateAsync(AdminAppointmentCreateRequest request)
    {
        return await CreateInternalAsync(request.UserId, request.StaffMemberId, request.Date, request.StartHour);
    }

    public async Task<AppointmentResponse> ConfirmAsync(int id)
    {
        var appointment = await GetEntityAsync(id);
        ChangeStatus(appointment, AppointmentStatus.Confirmed);
        await Db.SaveChangesAsync();
        return await GetByIdAsync(id);
    }

    public async Task<AppointmentResponse> CompleteAsync(int id)
    {
        var appointment = await GetEntityAsync(id);
        ChangeStatus(appointment, AppointmentStatus.Completed);
        await Db.SaveChangesAsync();
        return await GetByIdAsync(id);
    }

    public async Task<AppointmentResponse> CancelAsync(int id, AppointmentCancelRequest request)
    {
        var appointment = await GetEntityAsync(id);

        // clan smije otkazati samo vlastiti termin; admin bilo ciji
        if (!_currentUser.IsAdmin && appointment.UserId != _currentUser.UserId)
        {
            throw new BusinessException("Možete otkazati samo vlastite termine.");
        }

        ChangeStatus(appointment, AppointmentStatus.Cancelled);
        appointment.CancelledBy = _currentUser.IsAdmin ? CancellationActor.Admin : CancellationActor.User;
        appointment.CancellationReason = request.Reason;
        await Db.SaveChangesAsync();
        return await GetByIdAsync(id);
    }

    private async Task<AppointmentResponse> CreateInternalAsync(int userId, int staffMemberId, DateOnly date, int startHour)
    {
        var user = await Db.Users.FindAsync(userId)
            ?? throw new NotFoundException("Odabrani korisnik ne postoji.");
        if (user.Role != UserRole.GymMember)
        {
            throw new BusinessException("Termin se može zakazati samo za člana teretane.");
        }

        // slobodne satnice se provjeravaju na backendu u trenutku bookinga (race condition)
        var freeSlots = await GetFreeSlotsAsync(staffMemberId, date);
        if (!freeSlots.Contains(startHour))
        {
            throw new BusinessException("Odabrana satnica nije slobodna. Odaberite drugu.");
        }

        var appointment = new Appointment
        {
            UserId = userId,
            StaffMemberId = staffMemberId,
            Date = date,
            StartHour = startHour,
            Status = AppointmentStatus.Pending,
            CreatedAt = DateTime.UtcNow
        };
        Db.Appointments.Add(appointment);

        try
        {
            await Db.SaveChangesAsync();
        }
        catch (DbUpdateException)
        {
            // unique indeks (staff, datum, sat) je uhvatio istovremeni booking istog slota
            throw new BusinessException("Odabrana satnica je upravo zauzeta. Odaberite drugu.");
        }
        return await GetByIdAsync(appointment.Id);
    }

    private async Task<Appointment> GetEntityAsync(int id)
    {
        return await Db.Appointments.FindAsync(id)
            ?? throw new NotFoundException("Termin ne postoji.");
    }

    private static void ChangeStatus(Appointment appointment, AppointmentStatus newStatus)
    {
        if (!AllowedTransitions[appointment.Status].Contains(newStatus))
        {
            throw new BusinessException(
                $"Termin u statusu '{appointment.Status}' ne može preći u status '{newStatus}'.");
        }
        appointment.Status = newStatus;
        appointment.StatusChangedAt = DateTime.UtcNow;
    }

    private static async Task<PagedResult<AppointmentResponse>> ProjectPageAsync(
        IQueryable<Appointment> query, BaseSearchObject search)
    {
        var totalCount = await query.CountAsync();
        var items = await query
            .Skip((search.Page - 1) * search.PageSize)
            .Take(search.PageSize)
            .ProjectToType<AppointmentResponse>()
            .ToListAsync();
        return new PagedResult<AppointmentResponse> { Items = items, TotalCount = totalCount };
    }
}
