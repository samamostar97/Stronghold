using RabbitMQ.Client;

namespace Stronghold.Messaging;

public class RabbitMqConnection : IAsyncDisposable
{
    private IConnection? _connection;
    private IChannel? _channel;
    private readonly SemaphoreSlim _semaphore = new(1, 1);

    public async Task<IChannel> GetChannelAsync(CancellationToken ct = default)
    {
        if (_channel is { IsOpen: true })
            return _channel;

        await _semaphore.WaitAsync(ct);
        try
        {
            if (_channel is { IsOpen: true })
                return _channel;

            var host = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
            var port = int.TryParse(Environment.GetEnvironmentVariable("RABBITMQ_PORT"), out var p) ? p : 5672;
            var user = Environment.GetEnvironmentVariable("RABBITMQ_USER") ?? "guest";
            var password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest";

            var factory = new ConnectionFactory
            {
                HostName = host,
                Port = port,
                UserName = user,
                Password = password
            };

            for (var attempt = 1; attempt <= 2; attempt++)
            {
                try
                {
                    _connection = await factory.CreateConnectionAsync(ct);
                    _channel = await _connection.CreateChannelAsync(cancellationToken: ct);
                    return _channel;
                }
                catch when (attempt < 2)
                {
                    await Task.Delay(1000, ct);
                }
            }

            throw new InvalidOperationException("Unable to connect to RabbitMQ after 2 attempts.");
        }
        finally
        {
            _semaphore.Release();
        }
    }

    public async ValueTask DisposeAsync()
    {
        if (_channel != null)
            await _channel.CloseAsync();
        if (_connection != null)
            await _connection.CloseAsync();

        _channel?.Dispose();
        _connection?.Dispose();
        _semaphore.Dispose();
    }
}
