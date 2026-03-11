using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Stronghold.Domain.Enums;
using Stronghold.Infrastructure.Persistence;
using Stronghold.Messaging;
using Stronghold.Messaging.Events;

namespace Stronghold.Worker.ScheduledJobs;

public class ExpiredAppointmentJob : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly IMessagePublisher _messagePublisher;

    public ExpiredAppointmentJob(IServiceProvider serviceProvider, IMessagePublisher messagePublisher)
    {
        _serviceProvider = serviceProvider;
        _messagePublisher = messagePublisher;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        await WaitForDatabaseAsync(stoppingToken);

        using var timer = new PeriodicTimer(TimeSpan.FromHours(1));

        while (await timer.WaitForNextTickAsync(stoppingToken))
        {
            try
            {
                using var scope = _serviceProvider.CreateScope();
                var dbContext = scope.ServiceProvider.GetRequiredService<StrongholdDbContext>();

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

                    await _messagePublisher.PublishAsync(QueueNames.AppointmentExpired, new AppointmentExpiredEvent
                    {
                        Email = appointment.User.Email,
                        FirstName = appointment.User.FirstName,
                        StaffName = $"{appointment.Staff.FirstName} {appointment.Staff.LastName}",
                        ScheduledAt = appointment.ScheduledAt
                    }, stoppingToken);
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

    private async Task WaitForDatabaseAsync(CancellationToken ct)
    {
        for (var attempt = 1; attempt <= 30; attempt++)
        {
            try
            {
                using var scope = _serviceProvider.CreateScope();
                var dbContext = scope.ServiceProvider.GetRequiredService<StrongholdDbContext>();
                await dbContext.Database.CanConnectAsync(ct);
                return;
            }
            catch when (attempt < 30)
            {
                await Task.Delay(5000, ct);
            }
        }
    }
}
