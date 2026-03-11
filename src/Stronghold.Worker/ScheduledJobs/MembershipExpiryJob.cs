using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Stronghold.Infrastructure.Persistence;
using Stronghold.Messaging;
using Stronghold.Messaging.Events;

namespace Stronghold.Worker.ScheduledJobs;

public class MembershipExpiryJob : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly IMessagePublisher _messagePublisher;

    public MembershipExpiryJob(IServiceProvider serviceProvider, IMessagePublisher messagePublisher)
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
                var expiredMemberships = await dbContext.UserMemberships
                    .Include(m => m.User)
                    .Include(m => m.MembershipPackage)
                    .Where(m => m.IsActive && m.EndDate < now)
                    .ToListAsync(stoppingToken);

                foreach (var membership in expiredMemberships)
                {
                    membership.IsActive = false;

                    await _messagePublisher.PublishAsync(QueueNames.MembershipExpired, new MembershipExpiredEvent
                    {
                        Email = membership.User.Email,
                        FirstName = membership.User.FirstName,
                        PackageName = membership.MembershipPackage.Name
                    }, stoppingToken);
                }

                if (expiredMemberships.Count > 0)
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
