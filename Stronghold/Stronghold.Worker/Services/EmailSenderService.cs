using MailKit.Net.Smtp;
using MimeKit;

namespace Stronghold.Worker.Services;

public class EmailSenderService
{
    private readonly string _smtpHost;
    private readonly int _smtpPort;
    private readonly string _username;
    private readonly string _password;
    private readonly bool _useSsl;

    public EmailSenderService()
    {
        _smtpHost = Environment.GetEnvironmentVariable("SMTP_HOST")
            ?? throw new InvalidOperationException("SMTP_HOST is not configured");
        _smtpPort = int.Parse(Environment.GetEnvironmentVariable("SMTP_PORT")
            ?? throw new InvalidOperationException("SMTP_PORT is not configured"));
        _username = Environment.GetEnvironmentVariable("SMTP_USERNAME")
            ?? throw new InvalidOperationException("SMTP_USERNAME is not configured");
        _password = Environment.GetEnvironmentVariable("SMTP_PASSWORD")
            ?? throw new InvalidOperationException("SMTP_PASSWORD is not configured");
        _useSsl = bool.Parse(Environment.GetEnvironmentVariable("SMTP_USE_SSL")
            ?? throw new InvalidOperationException("SMTP_USE_SSL is not configured"));
    }

    public async Task SendEmailAsync(string toEmail, string subject, string body)
    {
        var message = new MimeMessage();
        message.From.Add(MailboxAddress.Parse(_username));
        message.To.Add(MailboxAddress.Parse(toEmail));
        message.Subject = subject;
        message.Body = new TextPart("html") { Text = body };

        using var client = new SmtpClient();
        var socketOptions = _useSsl
            ? MailKit.Security.SecureSocketOptions.StartTls
            : MailKit.Security.SecureSocketOptions.None;

        await client.ConnectAsync(_smtpHost, _smtpPort, socketOptions);
        await client.AuthenticateAsync(_username, _password);
        await client.SendAsync(message);
        await client.DisconnectAsync(true);
    }
}
