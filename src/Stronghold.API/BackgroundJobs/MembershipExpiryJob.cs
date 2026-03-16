using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Infrastructure.Persistence;
using Stronghold.Messaging;

namespace Stronghold.API.BackgroundJobs;

public class MembershipExpiryJob : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;

    public MembershipExpiryJob(IServiceProvider serviceProvider)
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
                var expiredMemberships = await dbContext.UserMemberships
                    .Include(m => m.User)
                    .Include(m => m.MembershipPackage)
                    .Where(m => m.IsActive && m.EndDate < now)
                    .ToListAsync(stoppingToken);

                foreach (var membership in expiredMemberships)
                {
                    membership.IsActive = false;

                    var packageName = !string.IsNullOrEmpty(membership.PackageName)
                        ? membership.PackageName
                        : membership.MembershipPackage?.Name ?? "-";

                    await publisher.PublishAsync(QueueNames.EmailNotifications,
                        EmailTemplates.MembershipExpired(
                            membership.User.Email,
                            membership.User.FirstName,
                            packageName),
                        stoppingToken);
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
}
