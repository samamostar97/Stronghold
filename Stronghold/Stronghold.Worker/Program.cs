using Stronghold.Worker;
using Stronghold.Worker.Services;

var builder = Host.CreateDefaultBuilder(args);

builder.ConfigureServices(services =>
{
    services.AddSingleton<EmailSenderService>();
    services.AddHostedService<Worker>();
});

var host = builder.Build();
host.Run();
