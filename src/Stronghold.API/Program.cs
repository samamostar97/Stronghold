using DotNetEnv;
using Microsoft.Extensions.FileProviders;
using QuestPDF.Infrastructure;
using Stronghold.API.Extensions;
using Stronghold.API.Middleware;
using Stronghold.Infrastructure.Persistence;
using Stronghold.Infrastructure.Persistence.Seeding;

// Load .env (for local dev; in Docker env vars come from docker-compose)
var envPath = Path.Combine(Directory.GetCurrentDirectory(), ".env");
if (!File.Exists(envPath))
    envPath = Path.Combine(Directory.GetCurrentDirectory(), "..", "..", ".env");
if (File.Exists(envPath))
    Env.Load(envPath);

// QuestPDF license
QuestPDF.Settings.License = LicenseType.Community;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

builder.Services.AddApplicationServices();
builder.Services.AddInfrastructureServices();
builder.Services.AddJwtAuthentication();
builder.Services.AddSwaggerServices();

builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader();
    });
});

var app = builder.Build();

// Seed database
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<StrongholdDbContext>();
    await context.Database.EnsureCreatedAsync();
    await AdminSeeder.SeedAsync(context);
    await LevelSeeder.SeedAsync(context);
}

app.UseMiddleware<ExceptionHandlingMiddleware>();

app.UseSwagger();
app.UseSwaggerUI();

app.UseCors();

// Serve uploaded files (profile images, staff images, etc.)
var uploadsPath = Environment.GetEnvironmentVariable("FILE_STORAGE_PATH") ?? "./uploads";
var uploadsFullPath = Path.GetFullPath(uploadsPath);
if (!Directory.Exists(uploadsFullPath))
    Directory.CreateDirectory(uploadsFullPath);
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(uploadsFullPath),
    RequestPath = ""
});

app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();
