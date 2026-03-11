using DotNetEnv;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Interfaces;
using Stronghold.Infrastructure.Persistence;
using Stronghold.Infrastructure.Services;
using Stronghold.Messaging;
using Stronghold.Worker.Consumers;
using Stronghold.Worker.ScheduledJobs;

var envPath = Path.Combine(AppContext.BaseDirectory, ".env");
if (File.Exists(envPath))
    Env.Load(envPath);

var builder = Host.CreateApplicationBuilder(args);

// Database
var dbHost = Environment.GetEnvironmentVariable("DB_HOST") ?? "localhost,1433";
var dbName = Environment.GetEnvironmentVariable("DB_NAME") ?? "StrongholdDb";
var dbUser = Environment.GetEnvironmentVariable("DB_USER") ?? "sa";
var dbPassword = Environment.GetEnvironmentVariable("DB_PASSWORD") ?? "YourStrong@Passw0rd123";

var connectionString = $"Server={dbHost};Database={dbName};User Id={dbUser};Password={dbPassword};TrustServerCertificate=True;";

builder.Services.AddDbContext<StrongholdDbContext>(options =>
    options.UseSqlServer(connectionString));

// RabbitMQ
builder.Services.AddSingleton<RabbitMqConnection>();
builder.Services.AddSingleton<IMessagePublisher, RabbitMqPublisher>();

// Email
builder.Services.AddScoped<IEmailService, EmailService>();

// Consumers
builder.Services.AddHostedService<UserRegisteredConsumer>();
builder.Services.AddHostedService<OrderConfirmedConsumer>();
builder.Services.AddHostedService<OrderShippedConsumer>();
builder.Services.AddHostedService<AppointmentApprovedConsumer>();
builder.Services.AddHostedService<AppointmentRejectedConsumer>();
builder.Services.AddHostedService<MembershipAssignedConsumer>();
builder.Services.AddHostedService<MembershipExpiredConsumer>();
builder.Services.AddHostedService<AppointmentExpiredConsumer>();
builder.Services.AddHostedService<UserLevelUpConsumer>();

// Scheduled Jobs
builder.Services.AddHostedService<MembershipExpiryJob>();
builder.Services.AddHostedService<ExpiredAppointmentJob>();

var host = builder.Build();
host.Run();
