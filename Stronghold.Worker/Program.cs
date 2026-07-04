using Microsoft.EntityFrameworkCore;
using Stronghold.Infrastructure.Data;
using Stronghold.Worker;

var builder = Host.CreateApplicationBuilder(args);

var connectionString = builder.Configuration["CONNECTION_STRING"]
    ?? throw new InvalidOperationException("Environment varijabla CONNECTION_STRING nije postavljena.");
builder.Services.AddDbContext<StrongholdDbContext>(options => options.UseSqlServer(connectionString));

builder.Services.AddSingleton<EmailSender>();
builder.Services.AddHostedService<EmailQueueWorker>();
builder.Services.AddHostedService<ReminderWorker>();

var host = builder.Build();
host.Run();
