using System.Text;
using System.Text.Json;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using Stronghold.Messaging;
using Stronghold.Messaging.Messages;
using Stronghold.Worker.Services;

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
        await Task.Delay(TimeSpan.FromSeconds(10), stoppingToken); // Wait for RabbitMQ

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
        var factory = new ConnectionFactory
        {
            HostName = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost",
            Port = int.Parse(Environment.GetEnvironmentVariable("RABBITMQ_PORT") ?? "5672"),
            UserName = Environment.GetEnvironmentVariable("RABBITMQ_USER") ?? "guest",
            Password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest"
        };

        _connection = factory.CreateConnection();
        _channel = _connection.CreateModel();

        _channel.QueueDeclare(
            queue: RabbitMqSettings.EmailQueue,
            durable: true,
            exclusive: false,
            autoDelete: false,
            arguments: null);

        _logger.LogInformation("Povezan na RabbitMQ, čekam email poruke...");
    }

    private void StartConsuming(CancellationToken stoppingToken)
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
                    _logger.LogInformation("Šaljem email na: {Email}", message.ToEmail);
                    await _emailSender.SendEmailAsync(message.ToEmail, message.Subject, message.Body);
                    _channel?.BasicAck(ea.DeliveryTag, false);
                    _logger.LogInformation("Email uspješno poslan na: {Email}", message.ToEmail);
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
    }

    public override void Dispose()
    {
        _channel?.Close();
        _connection?.Close();
        base.Dispose();
    }
}