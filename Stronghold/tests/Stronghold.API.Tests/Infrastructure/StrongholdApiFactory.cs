using System.Net.Http.Json;
using System.Text.Json;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.Extensions.Hosting;
using Stronghold.API.BackgroundServices;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;
using Stronghold.Infrastructure.Data;

namespace Stronghold.API.Tests.Infrastructure;

public sealed class StrongholdApiFactory : WebApplicationFactory<Program>
{
    public const string MemberUsername = "smoke_member";
    public const string AdminUsername = "smoke_admin";
    public const string Password = "SmokePass123!";

    private readonly string _databaseName = $"stronghold-api-tests-{Guid.NewGuid():N}";

    static StrongholdApiFactory()
    {
        Environment.SetEnvironmentVariable("JWT_SECRET", "super-secret-key-for-tests-1234567890");
        Environment.SetEnvironmentVariable("JWT_ISSUER", "Stronghold.Tests");
        Environment.SetEnvironmentVariable("JWT_AUDIENCE", "Stronghold.Tests.Client");
        Environment.SetEnvironmentVariable("STRIPE_SECRET_KEY", "sk_test_dummy");

        Environment.SetEnvironmentVariable("DB_SERVER", "localhost");
        Environment.SetEnvironmentVariable("DB_NAME", "stronghold_tests");
        Environment.SetEnvironmentVariable("DB_USER", "sa");
        Environment.SetEnvironmentVariable("DB_PASSWORD", "Password123!");
    }

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Testing");

        builder.ConfigureServices(services =>
        {
            services.RemoveAll<DbContextOptions<StrongholdDbContext>>();
            services.RemoveAll<StrongholdDbContext>();

            services.AddDbContext<StrongholdDbContext>(options =>
                options.UseInMemoryDatabase(_databaseName));

            var hostedServices = services
                .Where(x => x.ServiceType == typeof(IHostedService) &&
                    (x.ImplementationType == typeof(MembershipExpiryNotificationService) ||
                     x.ImplementationType == typeof(AppointmentReminderService)))
                .ToList();

            foreach (var descriptor in hostedServices)
            {
                services.Remove(descriptor);
            }
        });
    }

    public HttpClient CreateApiClient()
    {
        return CreateClient(new WebApplicationFactoryClientOptions
        {
            BaseAddress = new Uri("https://localhost"),
            AllowAutoRedirect = false
        });
    }

    public async Task ResetDatabaseAsync()
    {
        using var scope = Services.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<StrongholdDbContext>();

        await context.Database.EnsureDeletedAsync();
        await context.Database.EnsureCreatedAsync();

        var admin = new User
        {
            FirstName = "Admin",
            LastName = "Smoke",
            Username = AdminUsername,
            Email = "admin.smoke@example.com",
            PhoneNumber = "061000001",
            Gender = Gender.Male,
            Role = Role.Admin,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(Password)
        };

        var member = new User
        {
            FirstName = "Member",
            LastName = "Smoke",
            Username = MemberUsername,
            Email = "member.smoke@example.com",
            PhoneNumber = "061000002",
            Gender = Gender.Female,
            Role = Role.GymMember,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(Password)
        };

        var trainer = new Trainer
        {
            FirstName = "Trainer",
            LastName = "Smoke",
            Email = "trainer.smoke@example.com",
            PhoneNumber = "061000003"
        };

        context.Users.AddRange(admin, member);
        context.Trainers.Add(trainer);
        await context.SaveChangesAsync();

        context.Appointments.Add(new Appointment
        {
            UserId = member.Id,
            TrainerId = trainer.Id,
            AppointmentDate = DateTime.UtcNow.AddDays(2)
        });

        context.Orders.Add(new Order
        {
            UserId = member.Id,
            TotalAmount = 0m,
            PurchaseDate = DateTime.UtcNow.AddDays(-1),
            Status = OrderStatus.Processing
        });

        await context.SaveChangesAsync();
    }

    public async Task<string> LoginAndGetTokenAsync(HttpClient client, string username, string password)
    {
        var response = await client.PostAsJsonAsync("/api/Auth/login", new
        {
            username,
            password
        });
        response.EnsureSuccessStatusCode();

        var json = await response.Content.ReadAsStringAsync();
        using var document = JsonDocument.Parse(json);

        if (document.RootElement.TryGetProperty("token", out var tokenProperty))
        {
            return tokenProperty.GetString() ?? throw new InvalidOperationException("JWT token nedostaje.");
        }

        if (document.RootElement.TryGetProperty("Token", out tokenProperty))
        {
            return tokenProperty.GetString() ?? throw new InvalidOperationException("JWT token nedostaje.");
        }

        throw new InvalidOperationException("JWT token nije pronadjen u odgovoru.");
    }
}
