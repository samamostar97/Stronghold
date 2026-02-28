using Mapster;
using FluentValidation;
using MediatR;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Stronghold.Application.Common.Behaviors;
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

        // CQRS + Validation
        services.AddMediatR(typeof(ValidationBehavior<,>).Assembly);
        services.AddValidatorsFromAssembly(typeof(ValidationBehavior<,>).Assembly);
        services.AddTransient(typeof(IPipelineBehavior<,>), typeof(AuthorizationBehavior<,>));
        services.AddTransient(typeof(IPipelineBehavior<,>), typeof(ValidationBehavior<,>));

        // Stripe
        Stripe.StripeConfiguration.ApiKey = Environment.GetEnvironmentVariable("STRIPE_SECRET_KEY")
            ?? throw new InvalidOperationException("STRIPE_SECRET_KEY nije konfigurisan");

        // Repositories
        services.AddScoped<IFaqRepository, FaqRepository>();
        services.AddScoped<IMembershipPackageRepository, MembershipPackageRepository>();
        services.AddScoped<INutritionistRepository, NutritionistRepository>();
        services.AddScoped<ISeminarRepository, SeminarRepository>();
        services.AddScoped<IUserRepository, UserRepository>();
        services.AddScoped<ISupplierRepository, SupplierRepository>();
        services.AddScoped<ISupplementCategoryRepository, SupplementCategoryRepository>();
        services.AddScoped<ISupplementRepository, SupplementRepository>();
        services.AddScoped<IReviewRepository, ReviewRepository>();
        services.AddScoped<ITrainerRepository, TrainerRepository>();
        services.AddScoped<IAddressRepository, AddressRepository>();
        services.AddScoped<IVisitRepository, VisitRepository>();
        services.AddScoped<IMembershipRepository, MembershipRepository>();
        services.AddScoped<IOrderRepository, OrderRepository>();
        services.AddScoped<IAppointmentRepository, AppointmentRepository>();
        services.AddScoped<INotificationRepository, NotificationRepository>();

        // Services
        services.AddScoped<IJwtService, JwtService>();
        services.AddScoped<IReportReadService, ReportReadService>();
        services.AddScoped<IReportExportService, ReportExportService>();
        services.AddScoped<IUserProfileService, UserProfileService>();
        services.AddScoped<IEmailService, EmailService>();
        services.AddScoped<IStripePaymentService, StripePaymentService>();
        services.AddScoped<IOrderEmailService, OrderEmailService>();
        services.AddScoped<IRecommendationService, RecommendationService>();
        services.AddScoped<INotificationService, NotificationService>();
        services.AddScoped<IAdminActivityService, AdminActivityService>();
        services.AddScoped<ICurrentUserService, CurrentUserService>();

        // HTTP context
        services.AddHttpContextAccessor();

        // File storage
        services.AddScoped<IFileStorageService>(sp =>
        {
            return new FileStorageService(env.WebRootPath ?? Path.Combine(env.ContentRootPath, "wwwroot"));
        });

        // Background services
        services.AddHostedService<MembershipExpiryNotificationService>();
        services.AddHostedService<AppointmentReminderService>();

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
        const int maxRetries = 5;
        const int delaySeconds = 5;

        for (var attempt = 1; attempt <= maxRetries; attempt++)
        {
            try
            {
                using var scope = app.Services.CreateScope();
                var context = scope.ServiceProvider.GetRequiredService<StrongholdDbContext>();

                await StrongholdDbContextDataSeed.SeedAsync(context);
                Console.WriteLine("Database seeded successfully.");
                return;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Database seed attempt {attempt}/{maxRetries} failed: {ex.Message}");

                if (attempt < maxRetries)
                {
                    Console.WriteLine($"Retrying in {delaySeconds} seconds...");
                    await Task.Delay(TimeSpan.FromSeconds(delaySeconds));
                }
                else
                {
                    Console.WriteLine("All seed attempts failed. Starting API without seed data.");
                }
            }
        }
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
