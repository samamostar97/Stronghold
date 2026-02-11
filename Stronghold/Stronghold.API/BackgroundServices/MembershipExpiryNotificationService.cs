using Microsoft.EntityFrameworkCore;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Common;
using Stronghold.Infrastructure.Data;

namespace Stronghold.API.BackgroundServices;

public class MembershipExpiryNotificationService : BackgroundService
{
    private const string ReminderType = "membership-expiry";
    private const string EntityType = "Membership";

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

        var today = DateTimeUtils.LocalToday;
        var in1Day = today.AddDays(1);
        var in3Days = today.AddDays(3);

        var expiringIn3Days = await dbContext.Memberships
            .Include(m => m.User)
            .Include(m => m.MembershipPackage)
            .Where(m =>
                !m.User.IsDeleted &&
                !m.MembershipPackage.IsDeleted &&
                m.EndDate.Date == in3Days)
            .ToListAsync();

        var expiringIn1Day = await dbContext.Memberships
            .Include(m => m.User)
            .Include(m => m.MembershipPackage)
            .Where(m =>
                !m.User.IsDeleted &&
                !m.MembershipPackage.IsDeleted &&
                m.EndDate.Date == in1Day)
            .ToListAsync();

        _logger.LogInformation(
            "Found {Count3} memberships expiring in 3 days, {Count1} expiring in 1 day",
            expiringIn3Days.Count,
            expiringIn1Day.Count);

        foreach (var membership in expiringIn3Days)
        {
            await SendExpiryIfNeededAsync(dbContext, emailService, membership, 3);
        }

        foreach (var membership in expiringIn1Day)
        {
            await SendExpiryIfNeededAsync(dbContext, emailService, membership, 1);
        }
    }

    private async Task SendExpiryIfNeededAsync(
        StrongholdDbContext dbContext,
        IEmailService emailService,
        Membership membership,
        int daysRemaining)
    {
        var targetDate = membership.EndDate.Date;

        var alreadySent = await dbContext.ReminderDispatchLogs.AnyAsync(x =>
            x.ReminderType == ReminderType &&
            x.EntityType == EntityType &&
            x.EntityId == membership.Id &&
            x.DaysBeforeEvent == daysRemaining &&
            x.TargetDate == targetDate);

        if (alreadySent)
        {
            return;
        }

        var sent = await SendExpiryNotification(
            emailService,
            membership.User.Email,
            membership.User.FirstName,
            membership.MembershipPackage.PackageName,
            daysRemaining,
            membership.EndDate);

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
                EntityId = membership.Id,
                DaysBeforeEvent = daysRemaining,
                TargetDate = targetDate
            });

            await dbContext.SaveChangesAsync();
        }
        catch (DbUpdateException)
        {
            _logger.LogInformation(
                "Membership reminder log already exists (MembershipId: {MembershipId}, Days: {Days})",
                membership.Id,
                daysRemaining);
        }
    }

    private async Task<bool> SendExpiryNotification(
        IEmailService emailService,
        string email,
        string firstName,
        string packageName,
        int daysRemaining,
        DateTime expiryDate)
    {
        var subject = daysRemaining == 1
            ? "Vasa clanarina istice sutra!"
            : $"Vasa clanarina istice za {daysRemaining} dana";

        var body = $@"
            <html>
            <body style='font-family: Arial, sans-serif; line-height: 1.6;'>
                <h2>Pozdrav {firstName},</h2>
                <p>Obavjestavamo Vas da Vasa <strong>{packageName}</strong> clanarina istice
                   <strong>{expiryDate:dd.MM.yyyy}</strong>.</p>
                <p>Da biste nastavili koristiti usluge teretane Stronghold, molimo Vas da obnovite clanarinu.</p>
                <br/>
                <p>Srdacan pozdrav,<br/>Stronghold Tim</p>
            </body>
            </html>";

        try
        {
            await emailService.SendEmailAsync(email, subject, body);
            _logger.LogInformation("Queued {Days}-day expiry notification for {Email}", daysRemaining, email);
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to queue expiry notification for {Email}", email);
            return false;
        }
    }
}
