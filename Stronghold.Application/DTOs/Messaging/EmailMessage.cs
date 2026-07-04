namespace Stronghold.Application.DTOs.Messaging;

// Poruka koja ide na RabbitMQ queue - Worker je konzumira i salje e-mail.
public class EmailMessage
{
    public string To { get; set; } = null!;
    public string Subject { get; set; } = null!;
    public string Body { get; set; } = null!;
}
