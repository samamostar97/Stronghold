using Stronghold.Application.DTOs.Messaging;

namespace Stronghold.Application.Interfaces;

// Objavljuje e-mail poruke na RabbitMQ - slanje obavlja Worker u pozadini.
public interface IEmailPublisher
{
    void Publish(EmailMessage message);
}
