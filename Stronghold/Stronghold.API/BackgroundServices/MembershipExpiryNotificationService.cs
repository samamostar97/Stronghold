using Microsoft.EntityFrameworkCore;
using Stronghold.Application.IServices;
using Stronghold.Infrastructure.Data;

namespace Stronghold.API.BackgroundServices;

public class MembershipExpiryNotificationService : BackgroundService
{
    private readonly ILogger<MembershipExpiryNotificationService> _logger;
    private readonly IServiceProvider _serviceProvider;
    private readonly TimeSpan _checkInterval = TimeSpan.FromHours(24);

    public MembershipExpiryNotificationService(
        ILogger<MembershipExpiryNotificationService> logger,
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
                await CheckAndNotifyExpiringMemberships();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking expiring memberships");
            }

            await Task.Delay(_checkInterval, stoppingToken);
        }
    }

    private async Task CheckAndNotifyExpiringMemberships()
    {
        _logger.LogInformation("Checking for expiring memberships...");

        using var scope = _serviceProvider.CreateScope();
        var dbContext = scope.ServiceProvider.GetRequiredService<StrongholdDbContext>();
        var emailService = scope.ServiceProvider.GetRequiredService<IEmailService>();

        var today = DateTime.UtcNow.Date;
        var in1Day = today.AddDays(1);
        var in3Days = today.AddDays(3);

        // Get memberships expiring in exactly 3 days
        var expiringIn3Days = await dbContext.Memberships
            .Include(m => m.User)
            .Include(m => m.MembershipPackage)
            .Where(m => m.EndDate.Date == in3Days)
            .ToListAsync();

        // Get memberships expiring in exactly 1 day
        var expiringIn1Day = await dbContext.Memberships
            .Include(m => m.User)
            .Include(m => m.MembershipPackage)
            .Where(m => m.EndDate.Date == in1Day)
            .ToListAsync();

        _logger.LogInformation("Found {Count3} memberships expiring in 3 days, {Count1} expiring in 1 day",
            expiringIn3Days.Count, expiringIn1Day.Count);

        // Send 3-day warning emails
        foreach (var membership in expiringIn3Days)
        {
            await SendExpiryNotification(emailService, membership.User.Email, membership.User.FirstName,
                membership.MembershipPackage.PackageName, 3, membership.EndDate);
        }

        // Send 1-day warning emails
        foreach (var membership in expiringIn1Day)
        {
            await SendExpiryNotification(emailService, membership.User.Email, membership.User.FirstName,
                membership.MembershipPackage.PackageName, 1, membership.EndDate);
        }
    }

    private async Task SendExpiryNotification(IEmailService emailService, string email, string firstName,
        string packageName, int daysRemaining, DateTime expiryDate)
    {
        var subject = daysRemaining == 1
            ? "Vaša članarina ističe sutra!"
            : $"Vaša članarina ističe za {daysRemaining} dana";

        var body = $@"
            <html>
            <body style='font-family: Arial, sans-serif; line-height: 1.6;'>
                <h2>Pozdrav {firstName},</h2>
                <p>Obavještavamo Vas da Vaša <strong>{packageName}</strong> članarina ističe
                   <strong>{expiryDate:dd.MM.yyyy}</strong>.</p>
                <p>Da biste nastavili koristiti usluge teretane Stronghold, molimo Vas da obnovite članarinu.</p>
                <br/>
                <p>Srdačan pozdrav,<br/>Stronghold Tim</p>
            </body>
            </html>";

        try
        {
            await emailService.SendEmailAsync(email, subject, body);
            _logger.LogInformation("Queued {Days}-day expiry notification for {Email}", daysRemaining, email);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to queue expiry notification for {Email}", email);
        }
    }
}
