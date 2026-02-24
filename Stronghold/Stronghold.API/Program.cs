using Stronghold.API.Extensions;
using Stronghold.API.Middleware;

var builder = WebApplication.CreateBuilder(args);

// Add services (fluent chain)
builder.Services
    .AddInfrastructure(builder.Environment)
    .AddJwtAuthentication()
    .AddSwaggerWithAuth()
    .AddControllers();

var app = builder.Build();

// Seed database
if (!app.Environment.IsEnvironment("Testing"))
{
    await app.SeedDatabaseAsync();
}

// Configure pipeline
app.UseSwagger();
app.UseSwaggerUI();

app.UseMiddleware<ExceptionHandlerMiddleware>();
app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();

public partial class Program
{
}
