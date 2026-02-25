using System.Reflection;
using Microsoft.EntityFrameworkCore;
using Stronghold.API.BackgroundServices;
using Stronghold.API.Extensions;
using Stronghold.API.Middleware;
using Stronghold.Application.IServices;
using Stronghold.Infrastructure.Data;
using Stronghold.TestServer;

// --- Environment variables (hardcoded test values) ---
Environment.SetEnvironmentVariable("JWT_SECRET", "TestServerSuperSecretKey_AtLeast32Characters!");
Environment.SetEnvironmentVariable("JWT_ISSUER", "Stronghold");
Environment.SetEnvironmentVariable("JWT_AUDIENCE", "StrongholdApp");
Environment.SetEnvironmentVariable("STRIPE_SECRET_KEY", "sk_test_51SvL7dBlrIi9HZmr5XpTewWgBnPsbVYGwEXhpMRqcXhNUBXIV5U4oMrbzmFqZZaKqlPlPVZaFRiIJRMJxYRgJxd300I7Chv1Gw");
Environment.SetEnvironmentVariable("DB_SERVER", "not-used");
Environment.SetEnvironmentVariable("DB_NAME", "not-used");
Environment.SetEnvironmentVariable("DB_USER", "not-used");
Environment.SetEnvironmentVariable("DB_PASSWORD", "not-used");
Environment.SetEnvironmentVariable("ASPNETCORE_URLS", "http://localhost:5034");

var builder = WebApplication.CreateBuilder(args);

// Use the same service registration as the real API
builder.Services
    .AddInfrastructure(builder.Environment)
    .AddJwtAuthentication()
    .AddSwaggerWithAuth()
    .AddControllers();

// Override DbContext -> InMemory
var sqlServerDescriptor = builder.Services
    .FirstOrDefault(d => d.ServiceType == typeof(DbContextOptions<StrongholdDbContext>));
if (sqlServerDescriptor != null) builder.Services.Remove(sqlServerDescriptor);

var dbContextDescriptor = builder.Services
    .FirstOrDefault(d => d.ServiceType == typeof(StrongholdDbContext));
if (dbContextDescriptor != null) builder.Services.Remove(dbContextDescriptor);

// Remove all DbContextOptions registrations to avoid SQL Server provider
var dbOptionDescriptors = builder.Services
    .Where(d => d.ServiceType.IsGenericType &&
                d.ServiceType.GetGenericTypeDefinition() == typeof(DbContextOptions<>))
    .ToList();
foreach (var d in dbOptionDescriptors) builder.Services.Remove(d);

var dbOptionsNonGeneric = builder.Services
    .Where(d => d.ServiceType == typeof(DbContextOptions))
    .ToList();
foreach (var d in dbOptionsNonGeneric) builder.Services.Remove(d);

builder.Services.AddDbContext<StrongholdDbContext>(options =>
    options.UseInMemoryDatabase("StrongholdTestDb"));

// Stripe uses real service with test key from env var above

// Override Email -> Fake
var emailDescriptor = builder.Services
    .FirstOrDefault(d => d.ServiceType == typeof(IEmailService));
if (emailDescriptor != null) builder.Services.Remove(emailDescriptor);
builder.Services.AddScoped<IEmailService, FakeEmailService>();

// Remove background services (not needed for UI testing)
var hostedServiceDescriptors = builder.Services
    .Where(d => d.ServiceType == typeof(Microsoft.Extensions.Hosting.IHostedService) &&
                d.ImplementationType != null &&
                (d.ImplementationType == typeof(MembershipExpiryNotificationService) ||
                 d.ImplementationType == typeof(AppointmentReminderService)))
    .ToList();
foreach (var d in hostedServiceDescriptors) builder.Services.Remove(d);

var app = builder.Build();

// Seed the InMemory database using reflection (private methods, same order as SeedAsync minus MigrateAsync)
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<StrongholdDbContext>();
    await context.Database.EnsureCreatedAsync();

    var seedType = typeof(StrongholdDbContextDataSeed);
    var bindingFlags = BindingFlags.NonPublic | BindingFlags.Static;

    var seedMethods = new[]
    {
        "SeedMembershipPackagesAsync",
        "SeedSupplementCategoriesAsync",
        "SeedSuppliersAsync",
        "SeedSupplementsAsync",
        "SeedTrainersAsync",
        "SeedNutritionistsAsync",
        "SeedFAQsAsync",
        "SeedSeminarsAsync",
        "SeedUsersAsync",
        "SeedGymVisitsAsync",
        "SeedSeminarAttendeesAsync",
        "SeedMembershipsAsync",
        "SeedAppointmentsAsync",
        "SeedOrdersAsync",
        "SeedReviewsAsync",
        "SeedAddressesAsync"
    };

    foreach (var methodName in seedMethods)
    {
        var method = seedType.GetMethod(methodName, bindingFlags);
        if (method != null)
        {
            var task = (Task)method.Invoke(null, new object[] { context })!;
            await task;
        }
        else
        {
            Console.WriteLine($"Warning: Seed method '{methodName}' not found.");
        }
    }

    await context.SaveChangesAsync();
    Console.WriteLine("Database seeded successfully.");
}

// Same middleware pipeline as the real API
app.UseSwagger();
app.UseSwaggerUI();

app.UseMiddleware<ExceptionHandlerMiddleware>();
app.UseStaticFiles();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();
