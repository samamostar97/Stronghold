using Microsoft.EntityFrameworkCore;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Application.Common;
using Stronghold.Infrastructure.Data;

namespace Stronghold.API.BackgroundServices;

public class AppointmentReminderService : BackgroundService
{
    private const string ReminderType = "appointment";
    private const string EntityType = "Appointment";

    private readonly ILogger<AppointmentReminderService> _logger;
    private readonly IServiceProvider _serviceProvider;
    private readonly TimeSpan _checkInterval = TimeSpan.FromHours(24);

    public AppointmentReminderService(
        ILogger<AppointmentReminderService> logger,
        IServiceProvider serviceProvider)
    {
        _logger = logger;
        _serviceProvider = serviceProvider;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        await Task.Delay(TimeSpan.FromSeconds(30), stoppingToken);

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await CheckAndNotifyUpcomingAppointments();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking upcoming appointments");
            }

            await Task.Delay(_checkInterval, stoppingToken);
        }
    }

    private async Task CheckAndNotifyUpcomingAppointments()
    {
        _logger.LogInformation("Checking for upcoming appointments...");

        using var scope = _serviceProvider.CreateScope();
        var dbContext = scope.ServiceProvider.GetRequiredService<StrongholdDbContext>();
        var emailService = scope.ServiceProvider.GetRequiredService<IEmailService>();

        var today = StrongholdTimeUtils.LocalToday;
        var in1Day = today.AddDays(1);
        var in3Days = today.AddDays(3);

        var in3DaysList = await dbContext.Appointments
            .Include(a => a.User)
            .Include(a => a.Trainer)
            .Include(a => a.Nutritionist)
            .Where(a =>
                !a.User.IsDeleted &&
                (a.TrainerId == null || !a.Trainer!.IsDeleted) &&
                (a.NutritionistId == null || !a.Nutritionist!.IsDeleted) &&
                a.AppointmentDate.Date == in3Days)
            .ToListAsync();

        var in1DayList = await dbContext.Appointments
            .Include(a => a.User)
            .Include(a => a.Trainer)
            .Include(a => a.Nutritionist)
            .Where(a =>
                !a.User.IsDeleted &&
                (a.TrainerId == null || !a.Trainer!.IsDeleted) &&
                (a.NutritionistId == null || !a.Nutritionist!.IsDeleted) &&
                a.AppointmentDate.Date == in1Day)
            .ToListAsync();

        _logger.LogInformation(
            "Found {Count3} appointments in 3 days, {Count1} in 1 day",
            in3DaysList.Count,
            in1DayList.Count);

        foreach (var appointment in in3DaysList)
        {
            await SendReminderIfNeededAsync(dbContext, emailService, appointment, 3);
        }

        foreach (var appointment in in1DayList)
        {
            await SendReminderIfNeededAsync(dbContext, emailService, appointment, 1);
        }
    }

    private async Task SendReminderIfNeededAsync(
        StrongholdDbContext dbContext,
        IEmailService emailService,
        Appointment appointment,
        int daysUntil)
    {
        var targetDate = appointment.AppointmentDate.Date;

        var alreadySent = await dbContext.ReminderDispatchLogs.AnyAsync(x =>
            x.ReminderType == ReminderType &&
            x.EntityType == EntityType &&
            x.EntityId == appointment.Id &&
            x.DaysBeforeEvent == daysUntil &&
            x.TargetDate == targetDate);

        if (alreadySent)
        {
            return;
        }

        var professionalName = GetProfessionalName(appointment);
        var sent = await SendReminderEmail(
            emailService,
            appointment.User.Email,
            appointment.User.FirstName,
            professionalName,
            daysUntil,
            appointment.AppointmentDate);

        if (!sent)
        {
            return;
        }

        try
        {
            dbContext.ReminderDispatchLogs.Add(new ReminderDispatchLog
            {
                ReminderType = ReminderType,
                EntityType = EntityType,
                EntityId = appointment.Id,
                DaysBeforeEvent = daysUntil,
                TargetDate = targetDate
            });

            await dbContext.SaveChangesAsync();
        }
        catch (DbUpdateException)
        {
            _logger.LogInformation(
                "Appointment reminder log already exists (AppointmentId: {AppointmentId}, Days: {Days})",
                appointment.Id,
                daysUntil);
        }
    }

    private static string GetProfessionalName(Appointment appointment)
    {
        if (appointment.Trainer != null)
        {
            return $"trener {appointment.Trainer.FirstName} {appointment.Trainer.LastName}";
        }

        if (appointment.Nutritionist != null)
        {
            return $"nutricionist {appointment.Nutritionist.FirstName} {appointment.Nutritionist.LastName}";
        }

        return "strucnjak";
    }

    private async Task<bool> SendReminderEmail(
        IEmailService emailService,
        string email,
        string firstName,
        string professionalName,
        int daysUntil,
        DateTime appointmentDate)
    {
        var subject = daysUntil == 1
            ? "Vas termin je sutra!"
            : $"Vas termin je za {daysUntil} dana";

        var timeStr = appointmentDate.ToString("HH:mm");
        var dateStr = appointmentDate.ToString("dd.MM.yyyy");

        var body = $@"
            <html>
            <body style='font-family: Arial, sans-serif; line-height: 1.6;'>
                <h2>Pozdrav {firstName},</h2>
                <p>Podsjecamo Vas da imate zakazan termin sa <strong>{professionalName}</strong>
                   dana <strong>{dateStr}</strong> u <strong>{timeStr}</strong>.</p>
                <p>Molimo Vas da dodjete na vrijeme.</p>
                <br/>
                <p>Srdacan pozdrav,<br/>Stronghold Tim</p>
            </body>
            </html>";

        try
        {
            await emailService.SendEmailAsync(email, subject, body);
            _logger.LogInformation("Queued {Days}-day appointment reminder for {Email}", daysUntil, email);
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to queue appointment reminder for {Email}", email);
            return false;
        }
    }
}
