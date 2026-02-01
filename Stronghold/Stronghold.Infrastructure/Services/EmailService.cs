using System.Text;
using System.Text.Json;
using RabbitMQ.Client;
using Stronghold.Application.IServices;
using Stronghold.Messaging;
using Stronghold.Messaging.Messages;

namespace Stronghold.Infrastructure.Services;

public class EmailService : IEmailService, IDisposable
{
    private readonly IConnection _connection;
    private readonly IModel _channel;

    public EmailService()
    {
        var host = Environment.GetEnvironmentVariable("RABBITMQ_HOST")
            ?? throw new InvalidOperationException("RABBITMQ_HOST nije konfigurisan");
        var port = int.Parse(Environment.GetEnvironmentVariable("RABBITMQ_PORT")
            ?? throw new InvalidOperationException("RABBITMQ_PORT nije konfigurisan"));
        var user = Environment.GetEnvironmentVariable("RABBITMQ_USER")
            ?? throw new InvalidOperationException("RABBITMQ_USER nije konfigurisan");
        var password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD")
            ?? throw new InvalidOperationException("RABBITMQ_PASSWORD nije konfigurisan");

        var factory = new ConnectionFactory
        {
            HostName = host,
            Port = port,
            UserName = user,
            Password = password
        };

        _connection = factory.CreateConnection();
        _channel = _connection.CreateModel();

        _channel.QueueDeclare(
            queue: RabbitMqSettings.EmailQueue,
            durable: true,
            exclusive: false,
            autoDelete: false,
            arguments: null);
    }

    public Task SendEmailAsync(string toEmail, string subject, string body)
    {
        var message = new SendEmailMessage
        {
            ToEmail = toEmail,
            Subject = subject,
            Body = body
        };

        var json = JsonSerializer.Serialize(message);
        var messageBytes = Encoding.UTF8.GetBytes(json);

        var properties = _channel.CreateBasicProperties();
        properties.Persistent = true;

        _channel.BasicPublish(
            exchange: string.Empty,
            routingKey: RabbitMqSettings.EmailQueue,
            basicProperties: properties,
            body: messageBytes);

        return Task.CompletedTask;
    }

    public void Dispose()
    {
        _channel?.Close();
        _connection?.Close();
    }
}
