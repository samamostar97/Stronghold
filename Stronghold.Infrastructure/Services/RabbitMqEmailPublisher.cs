using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using RabbitMQ.Client;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Messaging;
using Stronghold.Application.Interfaces;

namespace Stronghold.Infrastructure.Services;

/// <summary>
/// Publisher e-mail poruka - registruje se kao SINGLETON, konekcija se otvara jednom
/// (nikad nova konekcija po publish-u) i lijeno, da API moze startati i prije RabbitMQ-a.
/// </summary>
public class RabbitMqEmailPublisher : IEmailPublisher, IDisposable
{
    private readonly ILogger<RabbitMqEmailPublisher> _logger;
    private readonly ConnectionFactory _factory;
    private readonly object _lock = new();

    private IConnection? _connection;
    private IModel? _channel;

    public RabbitMqEmailPublisher(IConfiguration configuration, ILogger<RabbitMqEmailPublisher> logger)
    {
        _logger = logger;
        // environment varijable se citaju jednom u konstruktoru
        _factory = new ConnectionFactory
        {
            HostName = configuration["RABBITMQ_HOST"]
                ?? throw new InvalidOperationException("Environment varijabla RABBITMQ_HOST nije postavljena."),
            Port = int.TryParse(configuration["RABBITMQ_PORT"], out var port) ? port : 5672,
            UserName = configuration["RABBITMQ_USER"]
                ?? throw new InvalidOperationException("Environment varijabla RABBITMQ_USER nije postavljena."),
            Password = configuration["RABBITMQ_PASS"]
                ?? throw new InvalidOperationException("Environment varijabla RABBITMQ_PASS nije postavljena.")
        };
    }

    public void Publish(EmailMessage message)
    {
        lock (_lock)
        {
            EnsureConnected();

            var body = Encoding.UTF8.GetBytes(JsonSerializer.Serialize(message));
            var properties = _channel!.CreateBasicProperties();
            properties.Persistent = true;

            _channel.BasicPublish(
                exchange: string.Empty,
                routingKey: MessagingConstants.EmailQueue,
                basicProperties: properties,
                body: body);

            _logger.LogInformation("E-mail poruka objavljena na queue (za: {To}, tema: {Subject}).",
                message.To, message.Subject);
        }
    }

    private void EnsureConnected()
    {
        if (_connection is { IsOpen: true } && _channel is { IsOpen: true })
        {
            return;
        }

        _channel?.Dispose();
        _connection?.Dispose();
        _connection = _factory.CreateConnection();
        _channel = _connection.CreateModel();
        _channel.QueueDeclare(queue: MessagingConstants.EmailQueue,
            durable: true, exclusive: false, autoDelete: false);
        _logger.LogInformation("Publisher povezan na RabbitMQ ({Host}).", _factory.HostName);
    }

    public void Dispose()
    {
        _channel?.Dispose();
        _connection?.Dispose();
    }
}
