using System.Text;
using System.Text.Json;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using Stronghold.Messaging;
using Stronghold.Messaging.Messages;
using Stronghold.Worker.Services;
using System.Threading;

namespace Stronghold.Worker;

public class EmailQueueConsumer : BackgroundService
{
    private readonly ILogger<EmailQueueConsumer> _logger;
    private readonly EmailSenderService _emailSender;
    private IConnection? _connection;
    private IModel? _channel;

    public EmailQueueConsumer(
        ILogger<EmailQueueConsumer> logger,
        EmailSenderService emailSender)
    {
        _logger = logger;
        _emailSender = emailSender;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        // wait a little for other services (db, rabbit) to become reachable
        await Task.Delay(TimeSpan.FromSeconds(10), stoppingToken);

        try
        {
            InitializeRabbitMq();
            StartConsuming(stoppingToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Greška pri povezivanju na RabbitMQ");
        }

        // Keep alive
        while (!stoppingToken.IsCancellationRequested)
        {
            await Task.Delay(TimeSpan.FromSeconds(30), stoppingToken);
        }
    }

    private void InitializeRabbitMq()
    {
        // Read env vars (may be missing in some runs). Pick safe defaults:
        var hostEnv = Environment.GetEnvironmentVariable("RABBITMQ_HOST");
        var portEnv = Environment.GetEnvironmentVariable("RABBITMQ_PORT");
        var userEnv = Environment.GetEnvironmentVariable("RABBITMQ_USER");
        var passEnv = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD");

        // When running in Docker compose, prefer the service name 'rabbitmq' if no host was provided.
        var defaultHost = Environment.GetEnvironmentVariable("DOTNET_RUNNING_IN_CONTAINER") == "true"
            ? "rabbitmq"
            : "localhost";

        var host = string.IsNullOrEmpty(hostEnv) ? defaultHost : hostEnv;
        var port = int.TryParse(portEnv, out var p) ? p : 5672;
        var user = string.IsNullOrEmpty(userEnv) ? "guest" : userEnv;
        var pass = string.IsNullOrEmpty(passEnv) ? "guest" : passEnv;

        var factory = new ConnectionFactory
        {
            HostName = host,
            Port = port,
            UserName = user,
            Password = pass,
            AutomaticRecoveryEnabled = true,
            NetworkRecoveryInterval = TimeSpan.FromSeconds(5)
        };

        // Try connect with a few retries because RabbitMQ may still be starting.
        const int maxAttempts = 6;
        var attempt = 0;
        Exception? lastEx = null;

        while (attempt < maxAttempts)
        {
            attempt++;
            try
            {
                _logger.LogInformation("Attempting to connect to RabbitMQ {Host}:{Port} (attempt {Attempt}/{Max})", host, port, attempt, maxAttempts);
                _connection = factory.CreateConnection();
                break;
            }
            catch (Exception ex)
            {
                lastEx = ex;
                _logger.LogWarning(ex, "Failed to connect to RabbitMQ on attempt {Attempt}. Retrying in {Delay}s...", attempt, 2 * attempt);
                Thread.Sleep(TimeSpan.FromSeconds(2 * attempt));
            }
        }

        if (_connection == null)
        {
            // let caller log and handle
            throw new InvalidOperationException("Unable to connect to RabbitMQ.", lastEx);
        }

        _channel = _connection.CreateModel();

        _channel.QueueDeclare(
            queue: RabbitMqSettings.EmailQueue,
            durable: true,
            exclusive: false,
            autoDelete: false,
            arguments: null);

        _logger.LogInformation("Connected to RabbitMQ at {Host}:{Port} and declared queue {Queue}", host, port, RabbitMqSettings.EmailQueue);
    }

    private void StartConsuming(CancellationToken stoppingToken)
    {
        if (_channel == null)
        {
            _logger.LogWarning("Channel is null, cannot start consuming.");
            return;
        }

        var consumer = new EventingBasicConsumer(_channel);

        consumer.Received += async (model, ea) =>
        {
            var body = ea.Body.ToArray();
            var json = Encoding.UTF8.GetString(body);

            try
            {
                var message = JsonSerializer.Deserialize<SendEmailMessage>(json);
                if (message != null)
                {
                    _logger.LogInformation("Šaljem email na: {Email}", message.ToEmail);
                    await _emailSender.SendEmailAsync(message.ToEmail, message.Subject, message.Body);
                    _channel?.BasicAck(ea.DeliveryTag, false);
                    _logger.LogInformation("Email uspješno poslan na: {Email}", message.ToEmail);
                }
                else
                {
                    _logger.LogWarning("Received null or invalid email message. Nacking.");
                    _channel?.BasicNack(ea.DeliveryTag, false, false);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Greška pri slanju emaila");
                // Requeue the message for retry
                _channel?.BasicNack(ea.DeliveryTag, false, true);
            }
        };

        _channel.BasicConsume(
            queue: RabbitMqSettings.EmailQueue,
            autoAck: false,
            consumer: consumer);

        _logger.LogInformation("Started consuming queue {Queue}", RabbitMqSettings.EmailQueue);
    }

    public override void Dispose()
    {
        _channel?.Close();
        _connection?.Close();
        base.Dispose();
    }
}

