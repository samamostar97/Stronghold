using Microsoft.Extensions.DependencyInjection;
using Stronghold.Application.Interfaces;
using Stronghold.Messaging;
using Stronghold.Messaging.Events;

namespace Stronghold.Worker.Consumers;

public class AppointmentExpiredConsumer : BaseConsumer<AppointmentExpiredEvent>
{
    protected override string QueueName => QueueNames.AppointmentExpired;

    public AppointmentExpiredConsumer(RabbitMqConnection connection, IServiceProvider serviceProvider)
        : base(connection, serviceProvider) { }

    protected override async Task HandleAsync(AppointmentExpiredEvent message, IServiceProvider scopedServices, CancellationToken ct)
    {
        var emailService = scopedServices.GetRequiredService<IEmailService>();
        await emailService.SendAppointmentExpiredAsync(message.Email, message.FirstName, message.StaffName, message.ScheduledAt);
    }
}
