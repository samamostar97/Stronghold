using Microsoft.Extensions.DependencyInjection;
using Stronghold.Application.Interfaces;
using Stronghold.Messaging;
using Stronghold.Messaging.Events;

namespace Stronghold.Worker.Consumers;

public class MembershipExpiredConsumer : BaseConsumer<MembershipExpiredEvent>
{
    protected override string QueueName => QueueNames.MembershipExpired;

    public MembershipExpiredConsumer(RabbitMqConnection connection, IServiceProvider serviceProvider)
        : base(connection, serviceProvider) { }

    protected override async Task HandleAsync(MembershipExpiredEvent message, IServiceProvider scopedServices, CancellationToken ct)
    {
        var emailService = scopedServices.GetRequiredService<IEmailService>();
        await emailService.SendMembershipExpiredAsync(message.Email, message.FirstName, message.PackageName);
    }
}
