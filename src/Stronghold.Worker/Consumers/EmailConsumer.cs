using System.Text;
using System.Text.Json;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using Stronghold.Application.Interfaces;
using Stronghold.Messaging;

namespace Stronghold.Worker.Consumers;

public class EmailConsumer : BackgroundService
{
    private readonly RabbitMqConnection _connection;
    private readonly IServiceProvider _serviceProvider;

    public EmailConsumer(RabbitMqConnection connection, IServiceProvider serviceProvider)
    {
        _connection = connection;
        _serviceProvider = serviceProvider;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        IChannel? channel = null;

        for (var attempt = 1; attempt <= 10; attempt++)
        {
            try
            {
                channel = await _connection.GetChannelAsync(stoppingToken);
                break;
            }
            catch when (attempt < 10)
            {
                await Task.Delay(3000, stoppingToken);
            }
        }

        if (channel == null) return;

        await channel.QueueDeclareAsync(
            queue: QueueNames.EmailNotifications,
            durable: true,
            exclusive: false,
            autoDelete: false,
            arguments: null,
            cancellationToken: stoppingToken);

        await channel.BasicQosAsync(prefetchSize: 0, prefetchCount: 1, global: false, cancellationToken: stoppingToken);

        var consumer = new AsyncEventingBasicConsumer(channel);
        consumer.ReceivedAsync += async (_, ea) =>
        {
            try
            {
                var body = Encoding.UTF8.GetString(ea.Body.ToArray());
                var message = JsonSerializer.Deserialize<EmailMessage>(body);

                if (message != null)
                {
                    using var scope = _serviceProvider.CreateScope();
                    var emailService = scope.ServiceProvider.GetRequiredService<IEmailService>();
                    await emailService.SendAsync(message.To, message.Subject, message.Body);
                }

                await channel.BasicAckAsync(ea.DeliveryTag, multiple: false, stoppingToken);
            }
            catch
            {
                await channel.BasicNackAsync(ea.DeliveryTag, multiple: false, requeue: true, cancellationToken: stoppingToken);
            }
        };

        await channel.BasicConsumeAsync(queue: QueueNames.EmailNotifications, autoAck: false, consumer: consumer, cancellationToken: stoppingToken);

        await Task.Delay(Timeout.Infinite, stoppingToken);
    }
}
