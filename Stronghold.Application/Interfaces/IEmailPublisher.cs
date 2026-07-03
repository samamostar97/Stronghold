using Stronghold.Application.DTOs.Messaging;

namespace Stronghold.Application.Interfaces;

/// <summary>Objavljuje e-mail poruke na RabbitMQ - slanje obavlja Worker u pozadini.</summary>
public interface IEmailPublisher
{
    void Publish(EmailMessage message);
}
