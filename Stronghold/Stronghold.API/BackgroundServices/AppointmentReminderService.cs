using Microsoft.EntityFrameworkCore;
using Stronghold.Application.IServices;
using Stronghold.Infrastructure.Data;

namespace Stronghold.API.BackgroundServices;

public class AppointmentReminderService : BackgroundService
{
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
        // Wait for app to fully start
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

        var today = DateTime.UtcNow.Date;
        var in1Day = today.AddDays(1);
        var in3Days = today.AddDays(3);

        // Get appointments in exactly 3 days
        var in3DaysList = await dbContext.Appointments
            .Include(a => a.User)
            .Include(a => a.Trainer)
            .Include(a => a.Nutritionist)
            .Where(a => a.AppointmentDate.Date == in3Days)
            .ToListAsync();

        // Get appointments in exactly 1 day
        var in1DayList = await dbContext.Appointments
            .Include(a => a.User)
            .Include(a => a.Trainer)
            .Include(a => a.Nutritionist)
            .Where(a => a.AppointmentDate.Date == in1Day)
            .ToListAsync();

        _logger.LogInformation("Found {Count3} appointments in 3 days, {Count1} in 1 day",
            in3DaysList.Count, in1DayList.Count);

        foreach (var appointment in in3DaysList)
        {
            var professionalName = GetProfessionalName(appointment);
            await SendReminderEmail(emailService, appointment.User.Email, appointment.User.FirstName,
                professionalName, 3, appointment.AppointmentDate);
        }

        foreach (var appointment in in1DayList)
        {
            var professionalName = GetProfessionalName(appointment);
            await SendReminderEmail(emailService, appointment.User.Email, appointment.User.FirstName,
                professionalName, 1, appointment.AppointmentDate);
        }
    }

    private static string GetProfessionalName(Stronghold.Core.Entities.Appointment appointment)
    {
        if (appointment.Trainer != null)
            return $"trener {appointment.Trainer.FirstName} {appointment.Trainer.LastName}";

        if (appointment.Nutritionist != null)
            return $"nutricionist {appointment.Nutritionist.FirstName} {appointment.Nutritionist.LastName}";

        return "stručnjak";
    }

    private async Task SendReminderEmail(IEmailService emailService, string email, string firstName,
        string professionalName, int daysUntil, DateTime appointmentDate)
    {
        var subject = daysUntil == 1
            ? "Vaš termin je sutra!"
            : $"Vaš termin je za {daysUntil} dana";

        var timeStr = appointmentDate.ToString("HH:mm");
        var dateStr = appointmentDate.ToString("dd.MM.yyyy");

        var body = $@"
            <html>
            <body style='font-family: Arial, sans-serif; line-height: 1.6;'>
                <h2>Pozdrav {firstName},</h2>
                <p>Podsjećamo Vas da imate zakazan termin sa <strong>{professionalName}</strong>
                   dana <strong>{dateStr}</strong> u <strong>{timeStr}</strong>.</p>
                <p>Molimo Vas da dođete na vrijeme.</p>
                <br/>
                <p>Srdačan pozdrav,<br/>Stronghold Tim</p>
            </body>
            </html>";

        try
        {
            await emailService.SendEmailAsync(email, subject, body);
            _logger.LogInformation("Queued {Days}-day appointment reminder for {Email}", daysUntil, email);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to queue appointment reminder for {Email}", email);
        }
    }
}
