using Microsoft.Extensions.DependencyInjection;
using Stronghold.Application.Interfaces;
using Stronghold.Messaging;
using Stronghold.Messaging.Events;

namespace Stronghold.Worker.Consumers;

public class OrderShippedConsumer : BaseConsumer<OrderShippedEvent>
{
    protected override string QueueName => QueueNames.OrderShipped;

    public OrderShippedConsumer(RabbitMqConnection connection, IServiceProvider serviceProvider)
        : base(connection, serviceProvider) { }

    protected override async Task HandleAsync(OrderShippedEvent message, IServiceProvider scopedServices, CancellationToken ct)
    {
        var emailService = scopedServices.GetRequiredService<IEmailService>();
        await emailService.SendOrderShippedAsync(message.Email, message.FirstName, message.OrderId);
    }
}
