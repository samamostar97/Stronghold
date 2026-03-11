using Microsoft.Extensions.DependencyInjection;
using Stronghold.Application.Interfaces;
using Stronghold.Messaging;
using Stronghold.Messaging.Events;

namespace Stronghold.Worker.Consumers;

public class AppointmentApprovedConsumer : BaseConsumer<AppointmentApprovedEvent>
{
    protected override string QueueName => QueueNames.AppointmentApproved;

    public AppointmentApprovedConsumer(RabbitMqConnection connection, IServiceProvider serviceProvider)
        : base(connection, serviceProvider) { }

    protected override async Task HandleAsync(AppointmentApprovedEvent message, IServiceProvider scopedServices, CancellationToken ct)
    {
        var emailService = scopedServices.GetRequiredService<IEmailService>();
        await emailService.SendAppointmentApprovedAsync(message.Email, message.FirstName, message.StaffName, message.ScheduledAt);
    }
}
