using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Domain.Enums;
using Stronghold.Infrastructure.Persistence;
using Stronghold.Messaging;

namespace Stronghold.API.BackgroundJobs;

public class ExpiredAppointmentJob : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;

    public ExpiredAppointmentJob(IServiceProvider serviceProvider)
    {
        _serviceProvider = serviceProvider;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        using var timer = new PeriodicTimer(TimeSpan.FromHours(1));

        while (await timer.WaitForNextTickAsync(stoppingToken))
        {
            try
            {
                using var scope = _serviceProvider.CreateScope();
                var dbContext = scope.ServiceProvider.GetRequiredService<StrongholdDbContext>();
                var publisher = scope.ServiceProvider.GetRequiredService<IMessagePublisher>();

                var now = DateTime.UtcNow;
                var expiredAppointments = await dbContext.Appointments
                    .Include(a => a.User)
                    .Include(a => a.Staff)
                    .Where(a => a.Status == AppointmentStatus.Pending && a.ScheduledAt < now)
                    .ToListAsync(stoppingToken);

                foreach (var appointment in expiredAppointments)
                {
                    appointment.IsDeleted = true;
                    appointment.DeletedAt = now;

                    await publisher.PublishAsync(QueueNames.EmailNotifications,
                        EmailTemplates.AppointmentExpired(
                            appointment.User.Email,
                            appointment.User.FirstName,
                            $"{appointment.Staff.FirstName} {appointment.Staff.LastName}",
                            appointment.ScheduledAt),
                        stoppingToken);
                }

                if (expiredAppointments.Count > 0)
                    await dbContext.SaveChangesAsync(stoppingToken);
            }
            catch
            {
                // Continue on next tick
            }
        }
    }
}
