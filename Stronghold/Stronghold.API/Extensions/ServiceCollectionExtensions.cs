using Mapster;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Infrastructure.Data;
using Stronghold.Infrastructure.Mapping;
using Stronghold.Infrastructure.Repositories;
using Stronghold.Infrastructure.Services;
using Stronghold.API.BackgroundServices;
using System.Text;

namespace Stronghold.API.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IWebHostEnvironment env)
    {
        // Database
        var connectionString = BuildConnectionString();
        services.AddDbContext<StrongholdDbContext>(options =>
            options.UseSqlServer(connectionString));

        // Mapster
        services.AddMapster();
        MappingConfig.Configure();

        // Stripe
        Stripe.StripeConfiguration.ApiKey = Environment.GetEnvironmentVariable("STRIPE_SECRET_KEY")
            ?? throw new InvalidOperationException("STRIPE_SECRET_KEY nije konfigurisan");

        // Repositories
        services.AddScoped(typeof(IRepository<,>), typeof(BaseRepository<,>));

        // Services
        services.AddScoped<IAuthService, AuthService>();
        services.AddScoped<IUserManagementService, UserManagementService>();
        services.AddScoped<IVisitService, VisitService>();
        services.AddScoped<IMembershipService, MembershipService>();
        services.AddScoped<IMembershipPackageService, MembershipPackageService>();
        services.AddScoped<ISupplementService, SupplementService>();
        services.AddScoped<ISupplierService, SupplierService>();
        services.AddScoped<ISupplementCategoryService, SupplementCategoryService>();
        services.AddScoped<INutritionistService, NutritionistService>();
        services.AddScoped<ITrainerService, TrainerService>();
        services.AddScoped<ISeminarService, SeminarService>();
        services.AddScoped<IReportService, ReportService>();
        services.AddScoped<IOrderService, OrderService>();
        services.AddScoped<IReviewService, ReviewService>();
        services.AddScoped<IFaqService, FaqService>();
        services.AddScoped<IUserProfileService, UserProfileService>();
        services.AddScoped<IAppointmentService, AppointmentService>();
        services.AddScoped<IEmailService, EmailService>();
        services.AddScoped<IRecommendationService, RecommendationService>();
        services.AddScoped<INotificationService, NotificationService>();
        services.AddScoped<IAddressService, AddressService>();

        // File storage
        services.AddScoped<IFileStorageService>(sp =>
        {
            return new FileStorageService(env.WebRootPath ?? Path.Combine(env.ContentRootPath, "wwwroot"));
        });

        // Background services
        services.AddHostedService<MembershipExpiryNotificationService>();

        return services;
    }

    public static IServiceCollection AddJwtAuthentication(this IServiceCollection services)
    {
        var jwtSecret = Environment.GetEnvironmentVariable("JWT_SECRET")
            ?? throw new InvalidOperationException("JWT_SECRET nije konfigurisan");
        var jwtIssuer = Environment.GetEnvironmentVariable("JWT_ISSUER")
            ?? throw new InvalidOperationException("JWT_ISSUER nije konfigurisan");
        var jwtAudience = Environment.GetEnvironmentVariable("JWT_AUDIENCE")
            ?? throw new InvalidOperationException("JWT_AUDIENCE nije konfigurisan");

        services.AddAuthentication(options =>
        {
            options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
            options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
        })
        .AddJwtBearer(options =>
        {
            options.TokenValidationParameters = new TokenValidationParameters
            {
                ValidateIssuer = true,
                ValidateAudience = true,
                ValidateLifetime = true,
                ValidateIssuerSigningKey = true,
                ValidIssuer = jwtIssuer,
                ValidAudience = jwtAudience,
                IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSecret))
            };
        });

        return services;
    }

    public static IServiceCollection AddSwaggerWithAuth(this IServiceCollection services)
    {
        services.AddEndpointsApiExplorer();
        services.AddSwaggerGen(c =>
        {
            c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
            {
                Name = "Authorization",
                Type = SecuritySchemeType.Http,
                Scheme = "bearer",
                BearerFormat = "JWT",
                In = ParameterLocation.Header,
                Description = "Unesi: Bearer {token}"
            });

            c.AddSecurityRequirement(new OpenApiSecurityRequirement
            {
                {
                    new OpenApiSecurityScheme
                    {
                        Reference = new OpenApiReference
                        {
                            Type = ReferenceType.SecurityScheme,
                            Id = "Bearer"
                        }
                    },
                    Array.Empty<string>()
                }
            });
        });

        return services;
    }

    public static async Task SeedDatabaseAsync(this WebApplication app)
    {
        if (!app.Environment.IsDevelopment())
            return;

        using var scope = app.Services.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<StrongholdDbContext>();

        var shouldClear = Environment.GetEnvironmentVariable("CLEAR_DATABASE")?.ToLower() == "true";
        if (shouldClear)
        {
            Console.WriteLine("Clearing database...");
            await StrongholdDbContextDataSeed.ClearDatabaseAsync(context);
            Console.WriteLine("Database cleared successfully.");
        }

        await StrongholdDbContextDataSeed.SeedAsync(context);
    }

    private static string BuildConnectionString()
    {
        return $"Server={Environment.GetEnvironmentVariable("DB_SERVER")};" +
               $"Database={Environment.GetEnvironmentVariable("DB_NAME")};" +
               $"User id={Environment.GetEnvironmentVariable("DB_USER")};" +
               $"Password={Environment.GetEnvironmentVariable("DB_PASSWORD")};" +
               "TrustServerCertificate=True;";
    }
}
