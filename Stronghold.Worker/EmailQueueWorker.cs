using System.Text;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;

namespace Stronghold.Worker;

/// <summary>
/// Slusa RabbitMQ queue za e-mail poruke. Konekcija je singleton (jedna po zivotu servisa),
/// a uspostavlja se sa eksponencijalnim backoff-om jer RabbitMQ u Dockeru
/// moze krenuti kasnije od workera.
/// </summary>
public class EmailQueueWorker : BackgroundService
{
    public const string QueueName = "stronghold.emails";

    private readonly ILogger<EmailQueueWorker> _logger;
    private readonly string _host;
    private readonly int _port;
    private readonly string _username;
    private readonly string _password;

    private IConnection? _connection;
    private IModel? _channel;

    public EmailQueueWorker(ILogger<EmailQueueWorker> logger, IConfiguration configuration)
    {
        _logger = logger;
        // environment varijable se citaju jednom u konstruktoru
        _host = configuration["RABBITMQ_HOST"]
            ?? throw new InvalidOperationException("Environment varijabla RABBITMQ_HOST nije postavljena.");
        _port = int.TryParse(configuration["RABBITMQ_PORT"], out var port) ? port : 5672;
        _username = configuration["RABBITMQ_USER"]
            ?? throw new InvalidOperationException("Environment varijabla RABBITMQ_USER nije postavljena.");
        _password = configuration["RABBITMQ_PASS"]
            ?? throw new InvalidOperationException("Environment varijabla RABBITMQ_PASS nije postavljena.");
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        await ConnectWithRetryAsync(stoppingToken);

        var consumer = new AsyncEventingBasicConsumer(_channel);
        consumer.Received += async (_, eventArgs) =>
        {
            var body = Encoding.UTF8.GetString(eventArgs.Body.ToArray());
            try
            {
                // Faza 15 ovdje dodaje stvarno slanje e-mailova preko SMTP-a
                _logger.LogInformation("Primljena poruka sa queue-a: {Body}", body);
                _channel!.BasicAck(eventArgs.DeliveryTag, multiple: false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Greska pri obradi poruke: {Body}", body);
                _channel!.BasicNack(eventArgs.DeliveryTag, multiple: false, requeue: true);
            }
            await Task.CompletedTask;
        };

        _channel.BasicConsume(queue: QueueName, autoAck: false, consumer: consumer);
        _logger.LogInformation("Worker slusa queue '{Queue}' na {Host}:{Port}.", QueueName, _host, _port);

        // drzi servis zivim dok se host ne ugasi
        await Task.Delay(Timeout.Infinite, stoppingToken);
    }

    private async Task ConnectWithRetryAsync(CancellationToken stoppingToken)
    {
        var factory = new ConnectionFactory
        {
            HostName = _host,
            Port = _port,
            UserName = _username,
            Password = _password,
            DispatchConsumersAsync = true
        };

        var delay = TimeSpan.FromSeconds(1);
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                _connection = factory.CreateConnection();
                _channel = _connection.CreateModel();
                _channel.QueueDeclare(queue: QueueName, durable: true, exclusive: false, autoDelete: false);
                _channel.BasicQos(prefetchSize: 0, prefetchCount: 1, global: false);
                _logger.LogInformation("Povezan na RabbitMQ ({Host}:{Port}).", _host, _port);
                return;
            }
            catch (Exception ex)
            {
                _logger.LogWarning("RabbitMQ nije dostupan ({Message}) - novi pokusaj za {Delay}s.",
                    ex.Message, delay.TotalSeconds);
                await Task.Delay(delay, stoppingToken);
                // eksponencijalni backoff: 1s -> 2s -> 4s -> 8s (maksimalno)
                if (delay < TimeSpan.FromSeconds(8))
                {
                    delay *= 2;
                }
            }
        }
    }

    public override void Dispose()
    {
        _channel?.Dispose();
        _connection?.Dispose();
        base.Dispose();
    }
}
