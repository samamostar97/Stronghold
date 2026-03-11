using Microsoft.Extensions.DependencyInjection;
using Stronghold.Application.Interfaces;
using Stronghold.Messaging;
using Stronghold.Messaging.Events;

namespace Stronghold.Worker.Consumers;

public class UserRegisteredConsumer : BaseConsumer<UserRegisteredEvent>
{
    protected override string QueueName => QueueNames.UserRegistered;

    public UserRegisteredConsumer(RabbitMqConnection connection, IServiceProvider serviceProvider)
        : base(connection, serviceProvider) { }

    protected override async Task HandleAsync(UserRegisteredEvent message, IServiceProvider scopedServices, CancellationToken ct)
    {
        var emailService = scopedServices.GetRequiredService<IEmailService>();
        await emailService.SendWelcomeAsync(message.Email, message.FirstName);
    }
}
