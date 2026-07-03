using System.Text;
using System.Text.Json;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Messaging;

namespace Stronghold.Worker;

/// <summary>
/// Slusa RabbitMQ queue i salje stvarne e-mailove (FIFO). Konekcija je singleton
/// (jedna po zivotu servisa), uspostavlja se sa eksponencijalnim backoff-om,
/// a neuspjelo slanje se ponavlja 1s -> 2s -> 4s -> 8s prije odustajanja.
/// </summary>
public class EmailQueueWorker : BackgroundService
{
    private const int MaxSendAttempts = 4;

    private readonly ILogger<EmailQueueWorker> _logger;
    private readonly EmailSender _emailSender;
    private readonly string _host;
    private readonly int _port;
    private readonly string _username;
    private readonly string _password;

    private IConnection? _connection;
    private IModel? _channel;

    public EmailQueueWorker(ILogger<EmailQueueWorker> logger, EmailSender emailSender, IConfiguration configuration)
    {
        _logger = logger;
        _emailSender = emailSender;
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
                var message = JsonSerializer.Deserialize<EmailMessage>(body)
                    ?? throw new JsonException("Poruka je prazna.");
                await SendWithRetryAsync(message, stoppingToken);
                _channel!.BasicAck(eventArgs.DeliveryTag, multiple: false);
            }
            catch (JsonException ex)
            {
                _logger.LogError(ex, "Nevalidna poruka na queue-u, odbacuje se: {Body}", body);
                _channel!.BasicNack(eventArgs.DeliveryTag, multiple: false, requeue: false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Slanje e-maila nije uspjelo nakon {Attempts} pokusaja: {Body}",
                    MaxSendAttempts, body);
                _channel!.BasicNack(eventArgs.DeliveryTag, multiple: false, requeue: false);
            }
        };

        _channel.BasicConsume(queue: MessagingConstants.EmailQueue, autoAck: false, consumer: consumer);
        _logger.LogInformation("Worker slusa queue '{Queue}' na {Host}:{Port}.",
            MessagingConstants.EmailQueue, _host, _port);

        // drzi servis zivim dok se host ne ugasi
        await Task.Delay(Timeout.Infinite, stoppingToken);
    }

    private async Task SendWithRetryAsync(EmailMessage message, CancellationToken stoppingToken)
    {
        var delay = TimeSpan.FromSeconds(1);
        for (var attempt = 1; ; attempt++)
        {
            try
            {
                await _emailSender.SendAsync(message, stoppingToken);
                _logger.LogInformation("E-mail poslan (za: {To}, tema: {Subject}).",
                    message.To, message.Subject);
                return;
            }
            catch (Exception ex) when (attempt < MaxSendAttempts)
            {
                _logger.LogWarning("Slanje e-maila nije uspjelo ({Message}) - pokusaj {Attempt}/{Max} za {Delay}s.",
                    ex.Message, attempt, MaxSendAttempts, delay.TotalSeconds);
                await Task.Delay(delay, stoppingToken);
                // eksponencijalni backoff: 1s -> 2s -> 4s -> 8s
                delay *= 2;
            }
        }
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
                _channel.QueueDeclare(queue: MessagingConstants.EmailQueue,
                    durable: true, exclusive: false, autoDelete: false);
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
