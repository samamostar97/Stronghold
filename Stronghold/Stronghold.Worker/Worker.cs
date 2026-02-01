using System.Text;
using System.Text.Json;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using Stronghold.Messaging;
using Stronghold.Messaging.Messages;
using Stronghold.Worker.Services;

namespace Stronghold.Worker;

public class Worker : BackgroundService
{
    private readonly ILogger<Worker> _logger;
    private readonly EmailSenderService _emailSender;
    private IConnection? _connection;
    private IModel? _channel;

    public Worker(ILogger<Worker> logger, EmailSenderService emailSender)
    {
        _logger = logger;
        _emailSender = emailSender;
    }

    public override Task StartAsync(CancellationToken cancellationToken)
    {
        var host = Environment.GetEnvironmentVariable("RABBITMQ_HOST")
            ?? throw new InvalidOperationException("RABBITMQ_HOST is not configured");
        var port = int.Parse(Environment.GetEnvironmentVariable("RABBITMQ_PORT")
            ?? throw new InvalidOperationException("RABBITMQ_PORT is not configured"));
        var user = Environment.GetEnvironmentVariable("RABBITMQ_USER")
            ?? throw new InvalidOperationException("RABBITMQ_USER is not configured");
        var password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD")
            ?? throw new InvalidOperationException("RABBITMQ_PASSWORD is not configured");

        var factory = new ConnectionFactory
        {
            HostName = host,
            Port = port,
            UserName = user,
            Password = password
        };

        // Retry connection to RabbitMQ
        var retries = 0;
        while (retries < 10)
        {
            try
            {
                _connection = factory.CreateConnection();
                _channel = _connection.CreateModel();
                _channel.QueueDeclare(
                    queue: RabbitMqSettings.EmailQueue,
                    durable: true,
                    exclusive: false,
                    autoDelete: false,
                    arguments: null);

                _channel.BasicQos(prefetchSize: 0, prefetchCount: 1, global: false);
                _logger.LogInformation("Connected to RabbitMQ at {Host}:{Port}", host, port);
                break;
            }
            catch (Exception ex)
            {
                retries++;
                _logger.LogWarning("Failed to connect to RabbitMQ (attempt {Retry}/10): {Message}", retries, ex.Message);
                Thread.Sleep(3000);
            }
        }

        if (_connection == null || !_connection.IsOpen)
        {
            _logger.LogError("Could not connect to RabbitMQ after 10 attempts");
            throw new InvalidOperationException("Could not connect to RabbitMQ");
        }

        return base.StartAsync(cancellationToken);
    }

    protected override Task ExecuteAsync(CancellationToken stoppingToken)
    {
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
                    _logger.LogInformation("Processing email to: {Email}", message.ToEmail);
                    await _emailSender.SendEmailAsync(message.ToEmail, message.Subject, message.Body);
                    _logger.LogInformation("Email sent successfully to: {Email}", message.ToEmail);
                }

                _channel!.BasicAck(ea.DeliveryTag, multiple: false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing email message: {Json}", json);
                _channel!.BasicNack(ea.DeliveryTag, multiple: false, requeue: true);
            }
        };

        _channel!.BasicConsume(
            queue: RabbitMqSettings.EmailQueue,
            autoAck: false,
            consumer: consumer);

        _logger.LogInformation("Worker started. Listening for messages on '{Queue}'...", RabbitMqSettings.EmailQueue);

        return Task.CompletedTask;
    }

    public override void Dispose()
    {
        _channel?.Close();
        _connection?.Close();
        base.Dispose();
    }
}
