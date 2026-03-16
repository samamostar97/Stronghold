using MailKit.Net.Smtp;
using MailKit.Security;
using MimeKit;
using Stronghold.Application.Interfaces;

namespace Stronghold.Infrastructure.Services;

public class EmailService : IEmailService
{
    private readonly string _smtpHost;
    private readonly int _smtpPort;
    private readonly string _smtpEmail;
    private readonly string _smtpPassword;

    public EmailService()
    {
        _smtpHost = Environment.GetEnvironmentVariable("SMTP_HOST") ?? "smtp.gmail.com";
        _smtpPort = int.TryParse(Environment.GetEnvironmentVariable("SMTP_PORT"), out var port) ? port : 587;
        _smtpEmail = Environment.GetEnvironmentVariable("SMTP_EMAIL") ?? "";
        _smtpPassword = Environment.GetEnvironmentVariable("SMTP_PASSWORD") ?? "";
    }

    public async Task SendAsync(string to, string subject, string htmlBody)
    {
        try
        {
            var message = new MimeMessage();
            message.From.Add(new MailboxAddress("Stronghold", _smtpEmail));
            message.To.Add(MailboxAddress.Parse(to));
            message.Subject = subject;

            var bodyBuilder = new BodyBuilder { HtmlBody = htmlBody };
            message.Body = bodyBuilder.ToMessageBody();

            using var client = new SmtpClient();
            await client.ConnectAsync(_smtpHost, _smtpPort, SecureSocketOptions.StartTls);
            await client.AuthenticateAsync(_smtpEmail, _smtpPassword);
            await client.SendAsync(message);
            await client.DisconnectAsync(true);
        }
        catch
        {
            // Silently skip - log in production
        }
    }
}
