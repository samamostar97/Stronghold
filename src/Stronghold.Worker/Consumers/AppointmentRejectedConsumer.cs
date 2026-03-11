using Microsoft.Extensions.DependencyInjection;
using Stronghold.Application.Interfaces;
using Stronghold.Messaging;
using Stronghold.Messaging.Events;

namespace Stronghold.Worker.Consumers;

public class AppointmentRejectedConsumer : BaseConsumer<AppointmentRejectedEvent>
{
    protected override string QueueName => QueueNames.AppointmentRejected;

    public AppointmentRejectedConsumer(RabbitMqConnection connection, IServiceProvider serviceProvider)
        : base(connection, serviceProvider) { }

    protected override async Task HandleAsync(AppointmentRejectedEvent message, IServiceProvider scopedServices, CancellationToken ct)
    {
        var emailService = scopedServices.GetRequiredService<IEmailService>();
        await emailService.SendAppointmentRejectedAsync(message.Email, message.FirstName, message.StaffName, message.ScheduledAt);
    }
}
