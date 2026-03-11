using Microsoft.Extensions.DependencyInjection;
using Stronghold.Application.Interfaces;
using Stronghold.Messaging;
using Stronghold.Messaging.Events;

namespace Stronghold.Worker.Consumers;

public class MembershipAssignedConsumer : BaseConsumer<MembershipAssignedEvent>
{
    protected override string QueueName => QueueNames.MembershipAssigned;

    public MembershipAssignedConsumer(RabbitMqConnection connection, IServiceProvider serviceProvider)
        : base(connection, serviceProvider) { }

    protected override async Task HandleAsync(MembershipAssignedEvent message, IServiceProvider scopedServices, CancellationToken ct)
    {
        var emailService = scopedServices.GetRequiredService<IEmailService>();
        await emailService.SendMembershipAssignedAsync(message.Email, message.FirstName, message.PackageName, message.EndDate);
    }
}
