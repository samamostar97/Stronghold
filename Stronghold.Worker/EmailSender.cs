using MailKit.Net.Smtp;
using MailKit.Security;
using MimeKit;
using Stronghold.Application.DTOs.Messaging;

namespace Stronghold.Worker;

/// <summary>Salje stvarne e-mailove preko SMTP-a. Konfiguracija se cita jednom u konstruktoru.</summary>
public class EmailSender
{
    private readonly string _host;
    private readonly int _port;
    private readonly string _email;
    private readonly string _password;

    public EmailSender(IConfiguration configuration)
    {
        _host = configuration["SMTP_HOST"]
            ?? throw new InvalidOperationException("Environment varijabla SMTP_HOST nije postavljena.");
        _port = int.TryParse(configuration["SMTP_PORT"], out var port) ? port : 587;
        _email = configuration["SMTP_EMAIL"]
            ?? throw new InvalidOperationException("Environment varijabla SMTP_EMAIL nije postavljena.");
        _password = configuration["SMTP_PASSWORD"]
            ?? throw new InvalidOperationException("Environment varijabla SMTP_PASSWORD nije postavljena.");
    }

    public async Task SendAsync(EmailMessage message, CancellationToken cancellationToken)
    {
        var mime = new MimeMessage();
        mime.From.Add(new MailboxAddress("Stronghold", _email));
        mime.To.Add(MailboxAddress.Parse(message.To));
        mime.Subject = message.Subject;
        mime.Body = new TextPart("plain") { Text = message.Body };

        using var client = new SmtpClient();
        await client.ConnectAsync(_host, _port, SecureSocketOptions.StartTls, cancellationToken);
        await client.AuthenticateAsync(_email, _password, cancellationToken);
        await client.SendAsync(mime, cancellationToken);
        await client.DisconnectAsync(quit: true, cancellationToken);
    }
}
