using Stronghold.Worker;
using Stronghold.Worker.Services;

var builder = Host.CreateApplicationBuilder(args);

builder.Services.AddSingleton<EmailSenderService>();
builder.Services.AddHostedService<EmailQueueConsumer>();

var host = builder.Build();
host.Run();
