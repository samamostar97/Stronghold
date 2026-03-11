using Microsoft.Extensions.DependencyInjection;
using Stronghold.Application.Interfaces;
using Stronghold.Messaging;
using Stronghold.Messaging.Events;

namespace Stronghold.Worker.Consumers;

public class UserLevelUpConsumer : BaseConsumer<UserLevelUpEvent>
{
    protected override string QueueName => QueueNames.UserLevelUp;

    public UserLevelUpConsumer(RabbitMqConnection connection, IServiceProvider serviceProvider)
        : base(connection, serviceProvider) { }

    protected override async Task HandleAsync(UserLevelUpEvent message, IServiceProvider scopedServices, CancellationToken ct)
    {
        var emailService = scopedServices.GetRequiredService<IEmailService>();
        await emailService.SendLevelUpAsync(message.Email, message.FirstName, message.LevelName);
    }
}
