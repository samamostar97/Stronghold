using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Logging;
using RabbitMQ.Client;
using Stronghold.Application.IServices;
using Stronghold.Messaging;
using Stronghold.Messaging.Messages;

namespace Stronghold.Infrastructure.Services;

public class EmailService : IEmailService, IDisposable
{
    private readonly ILogger<EmailService> _logger;
    private readonly Lazy<(IConnection? Connection, IModel? Channel)> _lazyConnection;
    private bool _disposed;

    public EmailService(ILogger<EmailService> logger)
    {
        _logger = logger;
        _lazyConnection = new Lazy<(IConnection?, IModel?)>(CreateConnection);
    }

    private (IConnection?, IModel?) CreateConnection()
    {
        try
        {
            var host = Environment.GetEnvironmentVariable("RABBITMQ_HOST");
            var portStr = Environment.GetEnvironmentVariable("RABBITMQ_PORT");
            var user = Environment.GetEnvironmentVariable("RABBITMQ_USER");
            var password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD");

            if (string.IsNullOrEmpty(host) || string.IsNullOrEmpty(portStr) ||
                string.IsNullOrEmpty(user) || string.IsNullOrEmpty(password))
            {
                _logger.LogWarning("RabbitMQ nije konfigurisan. Email funkcionalnost je onemogućena.");
                return (null, null);
            }

            var factory = new ConnectionFactory
            {
                HostName = host,
                Port = int.Parse(portStr),
                UserName = user,
                Password = password
            };

            var connection = factory.CreateConnection();
            var channel = connection.CreateModel();

            channel.QueueDeclare(
                queue: RabbitMqSettings.EmailQueue,
                durable: true,
                exclusive: false,
                autoDelete: false,
                arguments: null);

            _logger.LogInformation("Uspješno povezan na RabbitMQ");
            return (connection, channel);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Nije moguće povezati se na RabbitMQ. Email funkcionalnost je onemogućena.");
            return (null, null);
        }
    }

    public Task SendEmailAsync(string toEmail, string subject, string body)
    {
        var (_, channel) = _lazyConnection.Value;

        if (channel == null)
        {
            _logger.LogWarning("RabbitMQ nije dostupan. Email nije poslan na: {Email}", toEmail);
            return Task.CompletedTask;
        }

        var message = new SendEmailMessage
        {
            ToEmail = toEmail,
            Subject = subject,
            Body = body
        };

        var json = JsonSerializer.Serialize(message);
        var messageBytes = Encoding.UTF8.GetBytes(json);

        var properties = channel.CreateBasicProperties();
        properties.Persistent = true;

        channel.BasicPublish(
            exchange: string.Empty,
            routingKey: RabbitMqSettings.EmailQueue,
            basicProperties: properties,
            body: messageBytes);

        _logger.LogInformation("Email poruka poslana u queue za: {Email}", toEmail);
        return Task.CompletedTask;
    }

    public void Dispose()
    {
        if (_disposed) return;
        _disposed = true;

        if (_lazyConnection.IsValueCreated)
        {
            var (connection, channel) = _lazyConnection.Value;
            channel?.Close();
            connection?.Close();
        }
    }
}
