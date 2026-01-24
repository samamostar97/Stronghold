using DotNetEnv;
using Mapster;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Infrastructure.Data;
using Stronghold.Infrastructure.Repositories;
using Stronghold.Infrastructure.Services;
using Stronghold.Infrastructure.Mapping;
using Stronghold.API.Middleware;
using System.Text;


Env.Load();

var builder = WebApplication.CreateBuilder(args);

// Build connection string from environment variables
var connectionString = $"Server={Environment.GetEnvironmentVariable("DB_SERVER")};" +
                       $"Database={Environment.GetEnvironmentVariable("DB_NAME")};" +
                       $"User id={Environment.GetEnvironmentVariable("DB_USER")};" +
                       $"Password={Environment.GetEnvironmentVariable("DB_PASSWORD")};" +
                       "TrustServerCertificate=True;";

// Add services to the container.
builder.Services.AddDbContext<StrongholdDbContext>(options =>
    options.UseSqlServer(connectionString));
builder.Services.AddMapster();
MappingConfig.Configure();
// Register services
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped(typeof(IRepository<,>), typeof(BaseRepository<,>));
builder.Services.AddScoped<IAdminUserService, AdminUserService>();
builder.Services.AddScoped<IAdminVisitService, AdminVisitService>();
builder.Services.AddScoped<IAdminMembershipService, AdminMembershipService>();
builder.Services.AddScoped<IAdminPackageService, AdminPackageService>();
builder.Services.AddScoped<IAdminSupplementService, AdminSupplementService>();
builder.Services.AddScoped<IAdminSupplierService, AdminSupplierService>();
builder.Services.AddScoped<IAdminCategoryService, AdminCategoryService>();
builder.Services.AddScoped<IAdminNutritionistService, AdminNutritionistService>();
builder.Services.AddScoped<IAdminTrainerService, AdminTrainerService>();
builder.Services.AddScoped<IAdminSeminarService, AdminSeminarService>();
builder.Services.AddScoped<IReportService, ReportService>();
builder.Services.AddScoped<IAdminOrderService, AdminOrderService>();
builder.Services.AddScoped<IAdminReviewService, AdminReviewService>();
builder.Services.AddScoped<IAdminFaqService, AdminFaqService>();











// Configure JWT authentication
var jwtSecret = Environment.GetEnvironmentVariable("JWT_SECRET")
    ?? throw new InvalidOperationException("JWT_SECRET nije konfigurisan");
var jwtIssuer = Environment.GetEnvironmentVariable("JWT_ISSUER") ?? "Stronghold";
var jwtAudience = Environment.GetEnvironmentVariable("JWT_AUDIENCE") ?? "StrongholdApp";

builder.Services.AddAuthentication(options =>
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

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("Bearer", new Microsoft.OpenApi.Models.OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = Microsoft.OpenApi.Models.ParameterLocation.Header,
        Description = "Unesi: Bearer {token}"
    });

    c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement
    {
        {
            new Microsoft.OpenApi.Models.OpenApiSecurityScheme
            {
                Reference = new Microsoft.OpenApi.Models.OpenApiReference
                {
                    Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

var app = builder.Build();

// Seed the database in development
if (app.Environment.IsDevelopment())
{
    using var scope = app.Services.CreateScope();
    var context = scope.ServiceProvider.GetRequiredService<StrongholdDbContext>();

    // set CLEAR_DATABASE=true in .env for database clear
    var shouldClearDatabase = Environment.GetEnvironmentVariable("CLEAR_DATABASE")?.ToLower() == "true";
    if (shouldClearDatabase)
    {
        Console.WriteLine("Clearing database...");
        await StrongholdDbContextDataSeed.ClearDatabaseAsync(context);
        Console.WriteLine("Database cleared successfully.");
    }

    await StrongholdDbContextDataSeed.SeedAsync(context);
}

// Configure the HTTP request pipeline.
app.UseMiddleware<ExceptionHandlerMiddleware>();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthentication();

app.UseAuthorization();

app.MapControllers();

app.Run();
