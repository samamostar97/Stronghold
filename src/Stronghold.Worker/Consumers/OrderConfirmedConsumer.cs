using Microsoft.Extensions.DependencyInjection;
using Stronghold.Application.Interfaces;
using Stronghold.Messaging;
using Stronghold.Messaging.Events;

namespace Stronghold.Worker.Consumers;

public class OrderConfirmedConsumer : BaseConsumer<OrderConfirmedEvent>
{
    protected override string QueueName => QueueNames.OrderConfirmed;

    public OrderConfirmedConsumer(RabbitMqConnection connection, IServiceProvider serviceProvider)
        : base(connection, serviceProvider) { }

    protected override async Task HandleAsync(OrderConfirmedEvent message, IServiceProvider scopedServices, CancellationToken ct)
    {
        var emailService = scopedServices.GetRequiredService<IEmailService>();
        await emailService.SendOrderConfirmedAsync(message.Email, message.FirstName, message.OrderId, message.TotalAmount);
    }
}
