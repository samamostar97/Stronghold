using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.Messaging;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Worker;

/// <summary>
/// Periodicni job: jednom dnevno pospremi zaostala stanja (prosli termini, zaboravljeni
/// check-outi) i posalje podsjetnike (clanarine pri isteku, sutrasnji termini, nadolazeci
/// seminari) kao e-mail i in-app notifikaciju. Ovo je proizvodjac podsjetnika -
/// queue sam od sebe ne generise dogadjaje.
/// </summary>
public class ReminderWorker : BackgroundService
{
    private const int ReminderWindowDays = 3;
    private static readonly TimeSpan ScanInterval = TimeSpan.FromHours(24);

    private readonly ILogger<ReminderWorker> _logger;
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly EmailSender _emailSender;

    public ReminderWorker(
        ILogger<ReminderWorker> logger,
        IServiceScopeFactory scopeFactory,
        EmailSender emailSender)
    {
        _logger = logger;
        _scopeFactory = scopeFactory;
        _emailSender = emailSender;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        // kratka pauza da API stigne izvrsiti migracije na svjezoj bazi
        await Task.Delay(TimeSpan.FromSeconds(30), stoppingToken);

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await ScanAsync(stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Dnevni sken podsjetnika nije uspio - pokusava se ponovo sutra.");
            }
            await Task.Delay(ScanInterval, stoppingToken);
        }
    }

    private async Task ScanAsync(CancellationToken stoppingToken)
    {
        using var scope = _scopeFactory.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<StrongholdDbContext>();

        var now = DateTime.UtcNow;
        var windowEnd = now.AddDays(ReminderWindowDays);
        var sentCount = 0;

        var closedAppointments = await CloseExpiredAppointmentsAsync(db, now, stoppingToken);
        var closedVisits = await CloseStaleVisitsAsync(db, now, stoppingToken);

        // clanarine koje isticu u naredna 3 dana
        var expiring = await db.Memberships
            .Include(m => m.User)
            .Where(m => !m.IsRevoked && m.EndDate > now && m.EndDate <= windowEnd)
            .ToListAsync(stoppingToken);

        foreach (var membership in expiring)
        {
            // guard protiv dupliranja: jedan podsjetnik po korisniku u 24h
            var alreadyNotified = await db.Notifications.AnyAsync(n =>
                n.UserId == membership.UserId &&
                n.Type == NotificationType.MembershipExpiry &&
                n.CreatedAt > now.AddHours(-24), stoppingToken);
            if (alreadyNotified)
            {
                continue;
            }

            var daysLeft = (int)Math.Ceiling((membership.EndDate - now).TotalDays);
            var message = $"Vaša članarina ističe za {daysLeft} " +
                          $"{(daysLeft == 1 ? "dan" : "dana")} ({membership.EndDate:dd.MM.yyyy}). " +
                          "Produžite je na vrijeme.";

            db.Notifications.Add(new Notification
            {
                UserId = membership.UserId,
                Title = "Članarina uskoro ističe",
                Message = message,
                Type = NotificationType.MembershipExpiry,
                CreatedAt = now
            });
            await SendSafeAsync(membership.User.Email,
                "Stronghold - članarina uskoro ističe",
                $"Poštovani {membership.User.FirstName},\n\n{message}\n\nVaš Stronghold", stoppingToken);
            sentCount++;
        }

        // nadolazeci seminari u naredna 3 dana - podsjetnik prijavljenima
        var upcomingSeminars = await db.Seminars
            .Include(s => s.Registrations)
            .ThenInclude(r => r.User)
            .Where(s => s.ScheduledAt > now && s.ScheduledAt <= windowEnd)
            .ToListAsync(stoppingToken);

        foreach (var seminar in upcomingSeminars)
        {
            foreach (var registration in seminar.Registrations)
            {
                var alreadyNotified = await db.Notifications.AnyAsync(n =>
                    n.UserId == registration.UserId &&
                    n.Type == NotificationType.UpcomingSeminar &&
                    n.Message.Contains(seminar.Topic) &&
                    n.CreatedAt > now.AddHours(-24), stoppingToken);
                if (alreadyNotified)
                {
                    continue;
                }

                var message = $"Seminar \"{seminar.Topic}\" počinje {seminar.ScheduledAt:dd.MM.yyyy. u HH:mm}.";
                db.Notifications.Add(new Notification
                {
                    UserId = registration.UserId,
                    Title = "Nadolazeći seminar",
                    Message = message,
                    Type = NotificationType.UpcomingSeminar,
                    CreatedAt = now
                });
                await SendSafeAsync(registration.User.Email,
                    "Stronghold - podsjetnik na seminar",
                    $"Poštovani {registration.User.FirstName},\n\n{message}\n\nVaš Stronghold", stoppingToken);
                sentCount++;
            }
        }

        // sutrasnji termini - podsjetnik clanu
        var tomorrow = DateOnly.FromDateTime(now).AddDays(1);
        var tomorrowsAppointments = await db.Appointments
            .Include(a => a.User)
            .Include(a => a.StaffMember)
            .Where(a => a.Date == tomorrow &&
                        (a.Status == AppointmentStatus.Pending || a.Status == AppointmentStatus.Confirmed))
            .ToListAsync(stoppingToken);

        foreach (var appointment in tomorrowsAppointments)
        {
            var alreadyNotified = await db.Notifications.AnyAsync(n =>
                n.UserId == appointment.UserId &&
                n.Type == NotificationType.UpcomingAppointment &&
                n.CreatedAt > now.AddHours(-24), stoppingToken);
            if (alreadyNotified)
            {
                continue;
            }

            var staffName = $"{appointment.StaffMember.FirstName} {appointment.StaffMember.LastName}";
            var message = $"Sutra u {appointment.StartHour}:00 imate termin kod {staffName}.";
            db.Notifications.Add(new Notification
            {
                UserId = appointment.UserId,
                Title = "Podsjetnik na termin",
                Message = message,
                Type = NotificationType.UpcomingAppointment,
                CreatedAt = now
            });
            await SendSafeAsync(appointment.User.Email,
                "Stronghold - podsjetnik na termin",
                $"Poštovani {appointment.User.FirstName},\n\n{message}\n\nVaš Stronghold", stoppingToken);
            sentCount++;
        }

        await db.SaveChangesAsync(stoppingToken);
        _logger.LogInformation(
            "Dnevni sken zavrsen: {Closed} zatvorenih termina, {Visits} zatvorenih posjeta, " +
            "{Memberships} clanarina pri isteku, {Seminars} nadolazecih seminara, {Sent} podsjetnika.",
            closedAppointments, closedVisits, expiring.Count, upcomingSeminars.Count, sentCount);
    }

    /// <summary>
    /// Termini striktno prije danasnjeg dana: potvrdjeni se automatski zavrsavaju,
    /// a nepotvrdjeni otkazuju. Danasnji se ne diraju dok dan ne istekne.
    /// </summary>
    private static async Task<int> CloseExpiredAppointmentsAsync(
        StrongholdDbContext db, DateTime now, CancellationToken stoppingToken)
    {
        var today = DateOnly.FromDateTime(now);
        var stale = await db.Appointments
            .Where(a => a.Date < today &&
                        (a.Status == AppointmentStatus.Pending || a.Status == AppointmentStatus.Confirmed))
            .ToListAsync(stoppingToken);

        foreach (var appointment in stale)
        {
            if (appointment.Status == AppointmentStatus.Confirmed)
            {
                appointment.Status = AppointmentStatus.Completed;
            }
            else
            {
                appointment.Status = AppointmentStatus.Cancelled;
                appointment.CancelledBy = CancellationActor.System;
                appointment.CancellationReason = "Termin je prošao bez potvrde.";
                db.Notifications.Add(new Notification
                {
                    UserId = appointment.UserId,
                    Title = "Termin istekao",
                    Message = $"Termin {appointment.Date:dd.MM.yyyy}. u {appointment.StartHour}:00 " +
                              "nije potvrđen na vrijeme pa je automatski otkazan.",
                    Type = NotificationType.AppointmentStatusChanged,
                    CreatedAt = now
                });
            }
            appointment.StatusChangedAt = now;
        }
        return stale.Count;
    }

    /// <summary>
    /// Zaboravljeni check-out: posjete otvorene prethodnih dana zatvaraju se
    /// na kraj dana u kojem je clan usao, da popunjenost i XP ostanu tacni.
    /// </summary>
    private static async Task<int> CloseStaleVisitsAsync(
        StrongholdDbContext db, DateTime now, CancellationToken stoppingToken)
    {
        var stale = await db.GymVisits
            .Where(v => v.CheckOutAt == null && v.CheckInAt < now.Date)
            .ToListAsync(stoppingToken);

        foreach (var visit in stale)
        {
            visit.CheckOutAt = visit.CheckInAt.Date.AddDays(1);
        }
        return stale.Count;
    }

    private async Task SendSafeAsync(string to, string subject, string body, CancellationToken stoppingToken)
    {
        try
        {
            await _emailSender.SendAsync(new EmailMessage { To = to, Subject = subject, Body = body },
                stoppingToken);
        }
        catch (Exception ex)
        {
            // notifikacija u aplikaciji ostaje i kad e-mail ne prodje; razlog se uvijek loguje
            _logger.LogError(ex, "Slanje podsjetnika na {To} nije uspjelo.", to);
        }
    }
}
