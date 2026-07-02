using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Stronghold.API.Middleware;
using Stronghold.Application.Common;
using Stronghold.Application.Interfaces;
using Stronghold.Infrastructure;
using Stronghold.Infrastructure.Data;
using Stronghold.Infrastructure.Services;

var builder = WebApplication.CreateBuilder(args);

// sve konfiguracijske vrijednosti dolaze iz environment varijabli (.env preko docker-compose)
var connectionString = builder.Configuration["CONNECTION_STRING"]
    ?? throw new InvalidOperationException("Environment varijabla CONNECTION_STRING nije postavljena.");
var jwtKey = builder.Configuration["JWT_KEY"]
    ?? throw new InvalidOperationException("Environment varijabla JWT_KEY nije postavljena.");

builder.Services.AddDbContext<StrongholdDbContext>(options => options.UseSqlServer(connectionString));

builder.Services.AddControllers();

MapsterConfig.Register();

builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<ICurrentUserService, CurrentUserService>();
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<ICityService, CityService>();
builder.Services.AddScoped<IProfileService, ProfileService>();

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = AuthConstants.Issuer,
            ValidateAudience = true,
            ValidAudience = AuthConstants.Audience,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
            ClockSkew = TimeSpan.FromSeconds(30)
        };
    });
builder.Services.AddAuthorization();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo { Title = "Stronghold API", Version = "v1" });
    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Unesite JWT token dobijen na login endpointu."
    });
    options.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" }
            },
            Array.Empty<string>()
        }
    });
});

var app = builder.Build();

app.UseMiddleware<ExceptionHandlingMiddleware>();

app.UseSwagger();
app.UseSwaggerUI();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

// migracije + seed pri startu, sa retry petljom dok SQL Server ne postane dostupan
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<StrongholdDbContext>();
    var logger = scope.ServiceProvider.GetRequiredService<ILoggerFactory>().CreateLogger("DatabaseInitializer");
    await DatabaseInitializer.InitializeAsync(db, logger);
}

app.Run();

