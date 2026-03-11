using System.Text;
using System.Text.Json;
using RabbitMQ.Client;

namespace Stronghold.Messaging;

public class RabbitMqPublisher : IMessagePublisher
{
    private readonly RabbitMqConnection _connection;

    public RabbitMqPublisher(RabbitMqConnection connection)
    {
        _connection = connection;
    }

    public async Task PublishAsync<T>(string queueName, T message, CancellationToken ct = default)
    {
        try
        {
            var channel = await _connection.GetChannelAsync(ct);

            await channel.QueueDeclareAsync(
                queue: queueName,
                durable: true,
                exclusive: false,
                autoDelete: false,
                arguments: null,
                cancellationToken: ct);

            var body = Encoding.UTF8.GetBytes(JsonSerializer.Serialize(message));

            var properties = new BasicProperties
            {
                Persistent = true
            };

            await channel.BasicPublishAsync(
                exchange: string.Empty,
                routingKey: queueName,
                mandatory: false,
                basicProperties: properties,
                body: body,
                cancellationToken: ct);
        }
        catch
        {
            // Silently skip if RabbitMQ is not available
        }
    }
}
