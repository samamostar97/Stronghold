using DotNetEnv;
using Stronghold.API.Extensions;
using Stronghold.API.Middleware;
using Stronghold.Infrastructure.Persistence;
using Stronghold.Infrastructure.Persistence.Seeding;

// Load .env
Env.Load();

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
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();
