using DotNetEnv;
using Stronghold.API.Extensions;
using Stronghold.API.Middleware;

if (Environment.GetEnvironmentVariable("DOTNET_RUNNING_IN_CONTAINER") != "true")
    Env.Load();

var builder = WebApplication.CreateBuilder(args);

// Add services (fluent chain)
builder.Services
    .AddInfrastructure(builder.Environment)
    .AddJwtAuthentication()
    .AddSwaggerWithAuth()
    .AddControllers();

var app = builder.Build();

// Seed database (development only)
await app.SeedDatabaseAsync();

// Configure pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseMiddleware<ExceptionHandlerMiddleware>();
app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();
