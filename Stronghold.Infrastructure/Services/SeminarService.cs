using Mapster;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Messaging;
using Stronghold.Application.DTOs.Seminars;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Interfaces;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Services;

public class SeminarService
    : BaseCrudService<Seminar, SeminarResponse, SeminarSearch, SeminarUpsertRequest, SeminarUpsertRequest>,
      ISeminarService
{
    private readonly ICurrentUserService _currentUser;
    private readonly IEmailPublisher _emailPublisher;
    private readonly ActivityLogInterceptor _activityLogInterceptor;

    public SeminarService(
        StrongholdDbContext db,
        ICurrentUserService currentUser,
        IEmailPublisher emailPublisher,
        ActivityLogInterceptor activityLogInterceptor) : base(db)
    {
        _currentUser = currentUser;
        _emailPublisher = emailPublisher;
        _activityLogInterceptor = activityLogInterceptor;
    }

    protected override IQueryable<Seminar> ApplyFilter(IQueryable<Seminar> query, SeminarSearch search)
    {
        if (!string.IsNullOrWhiteSpace(search.Text))
        {
            var text = search.Text.Trim();
            query = query.Where(s => s.Topic.Contains(text) || s.Speaker.Contains(text));
        }
        if (search.OnlyUpcoming == true)
        {
            query = query.Where(s => s.ScheduledAt > DateTime.UtcNow);
        }
        return query.OrderBy(s => s.ScheduledAt);
    }

    public override async Task<PagedResult<SeminarResponse>> GetPagedAsync(SeminarSearch search)
    {
        var result = await base.GetPagedAsync(search);
        await MarkCurrentUserRegistrationsAsync(result.Items);
        return result;
    }

    public override async Task<SeminarResponse> GetByIdAsync(int id)
    {
        var response = await base.GetByIdAsync(id);
        await MarkCurrentUserRegistrationsAsync(new List<SeminarResponse> { response });
        return response;
    }

    protected override async Task BeforeUpdateAsync(Seminar entity, SeminarUpsertRequest request)
    {
        if (entity.IsCancelled)
        {
            throw new BusinessException("Otkazani seminar se ne može mijenjati.");
        }

        var registeredCount = await Db.SeminarRegistrations.CountAsync(r => r.SeminarId == entity.Id);
        if (request.MaxCapacity < registeredCount)
        {
            throw new BusinessException(
                $"Kapacitet se ne može smanjiti ispod broja već prijavljenih učesnika ({registeredCount}).");
        }
    }

    protected override async Task BeforeDeleteAsync(Seminar entity)
    {
        if (await Db.SeminarRegistrations.AnyAsync(r => r.SeminarId == entity.Id))
        {
            throw new BusinessException("Seminar se ne može obrisati jer ima prijavljene učesnike.");
        }
    }

    public async Task<SeminarResponse> RegisterAsync(int seminarId)
    {
        var seminar = await Db.Seminars.FindAsync(seminarId)
            ?? throw new NotFoundException("Seminar ne postoji.");

        if (seminar.IsCancelled)
        {
            throw new BusinessException("Seminar je otkazan - prijava nije moguća.");
        }
        if (seminar.ScheduledAt <= DateTime.UtcNow)
        {
            throw new BusinessException("Prijava na seminar koji je već održan nije moguća.");
        }

        var userId = _currentUser.UserId;
        if (await Db.SeminarRegistrations.AnyAsync(r => r.SeminarId == seminarId && r.UserId == userId))
        {
            throw new BusinessException("Već ste prijavljeni na ovaj seminar.");
        }

        // provjera kapaciteta na backendu, ne samo prikaz preostalih mjesta
        var registeredCount = await Db.SeminarRegistrations.CountAsync(r => r.SeminarId == seminarId);
        if (registeredCount >= seminar.MaxCapacity)
        {
            throw new BusinessException("Seminar je popunjen - nema slobodnih mjesta.");
        }

        Db.SeminarRegistrations.Add(new SeminarRegistration
        {
            SeminarId = seminarId,
            UserId = userId,
            RegisteredAt = DateTime.UtcNow
        });
        await Db.SaveChangesAsync();
        return await GetByIdAsync(seminarId);
    }

    /// <summary>Odjava oslobadja mjesto drugima - moguca do pocetka seminara.</summary>
    public async Task<SeminarResponse> UnregisterAsync(int seminarId)
    {
        var seminar = await Db.Seminars.FindAsync(seminarId)
            ?? throw new NotFoundException("Seminar ne postoji.");

        if (seminar.ScheduledAt <= DateTime.UtcNow)
        {
            throw new BusinessException("Odjava sa seminara koji je već počeo nije moguća.");
        }

        var userId = _currentUser.UserId;
        var registration = await Db.SeminarRegistrations
            .FirstOrDefaultAsync(r => r.SeminarId == seminarId && r.UserId == userId)
            ?? throw new BusinessException("Niste prijavljeni na ovaj seminar.");

        Db.SeminarRegistrations.Remove(registration);
        await Db.SaveChangesAsync();
        return await GetByIdAsync(seminarId);
    }

    /// <summary>Otkaz obavjestava sve prijavljene (in-app + e-mail); seminar ostaje u evidenciji.</summary>
    public async Task<SeminarResponse> CancelAsync(int seminarId, SeminarCancelRequest request)
    {
        var seminar = await Db.Seminars
            .Include(s => s.Registrations)
            .ThenInclude(r => r.User)
            .FirstOrDefaultAsync(s => s.Id == seminarId)
            ?? throw new NotFoundException("Seminar ne postoji.");

        if (seminar.IsCancelled)
        {
            throw new BusinessException("Seminar je već otkazan.");
        }
        if (seminar.ScheduledAt <= DateTime.UtcNow)
        {
            throw new BusinessException("Seminar koji je već održan ne može se otkazati.");
        }

        // otkaz je poslovna operacija sa nepovratnim efektima (mailovi), ne CRUD - bez undo
        using var suppression = _activityLogInterceptor.Suppress();

        seminar.IsCancelled = true;
        seminar.CancelledAt = DateTime.UtcNow;
        seminar.CancellationReason = request.Reason;

        var message = $"Seminar \"{seminar.Topic}\" ({seminar.ScheduledAt:dd.MM.yyyy. u HH:mm}) " +
                      $"je otkazan. Razlog: {request.Reason}";
        foreach (var registration in seminar.Registrations)
        {
            Db.Notifications.Add(new Notification
            {
                UserId = registration.UserId,
                Title = "Seminar otkazan",
                Message = message,
                Type = NotificationType.SeminarCancelled,
                CreatedAt = DateTime.UtcNow
            });
            _emailPublisher.Publish(new EmailMessage
            {
                To = registration.User.Email,
                Subject = "Stronghold - seminar otkazan",
                Body = $"Poštovani {registration.User.FirstName},\n\n{message}\n\nVaš Stronghold"
            });
        }

        await Db.SaveChangesAsync();
        return await GetByIdAsync(seminarId);
    }

    public async Task<List<SeminarRegistrationResponse>> GetRegistrationsAsync(int seminarId)
    {
        if (!await Db.Seminars.AnyAsync(s => s.Id == seminarId))
        {
            throw new NotFoundException("Seminar ne postoji.");
        }

        return await Db.SeminarRegistrations.AsNoTracking()
            .Where(r => r.SeminarId == seminarId)
            .OrderBy(r => r.RegisteredAt)
            .ProjectToType<SeminarRegistrationResponse>()
            .ToListAsync();
    }

    private async Task MarkCurrentUserRegistrationsAsync(List<SeminarResponse> seminars)
    {
        if (seminars.Count == 0)
        {
            return;
        }

        var seminarIds = seminars.Select(s => s.Id).ToList();
        var userId = _currentUser.UserId;
        var registeredIds = await Db.SeminarRegistrations.AsNoTracking()
            .Where(r => r.UserId == userId && seminarIds.Contains(r.SeminarId))
            .Select(r => r.SeminarId)
            .ToListAsync();

        foreach (var seminar in seminars)
        {
            seminar.IsCurrentUserRegistered = registeredIds.Contains(seminar.Id);
        }
    }
}
