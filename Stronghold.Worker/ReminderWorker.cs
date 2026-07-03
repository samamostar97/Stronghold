using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.Messaging;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Worker;

/// <summary>
/// Periodicni job: jednom dnevno skenira clanarine koje isticu i nadolazece seminare,
/// pa salje e-mail i kreira in-app notifikaciju. Ovo je proizvodjac podsjetnika -
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

        await db.SaveChangesAsync(stoppingToken);
        _logger.LogInformation(
            "Dnevni sken zavrsen: {Memberships} clanarina pri isteku, {Seminars} nadolazecih seminara, {Sent} podsjetnika.",
            expiring.Count, upcomingSeminars.Count, sentCount);
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
