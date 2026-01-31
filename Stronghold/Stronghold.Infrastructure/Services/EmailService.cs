using MailKit.Net.Smtp;
using MimeKit;
using Stronghold.Application.IServices;

namespace Stronghold.Infrastructure.Services;

public class EmailService : IEmailService
{
    private readonly string _fromEmail;
    private readonly string _appPassword;

    public EmailService()
    {
        _fromEmail = Environment.GetEnvironmentVariable("EMAIL_FROM")
            ?? throw new InvalidOperationException("EMAIL_FROM nije konfigurisan.");
        _appPassword = Environment.GetEnvironmentVariable("EMAIL_APP_PASSWORD")
            ?? throw new InvalidOperationException("EMAIL_APP_PASSWORD nije konfigurisan.");
    }

    public async Task SendEmailAsync(string toEmail, string subject, string body)
    {
        var message = new MimeMessage();
        message.From.Add(MailboxAddress.Parse(_fromEmail));
        message.To.Add(MailboxAddress.Parse(toEmail));
        message.Subject = subject;
        message.Body = new TextPart("html") { Text = body };

        using var client = new SmtpClient();
        await client.ConnectAsync("smtp.gmail.com", 587, MailKit.Security.SecureSocketOptions.StartTls);
        await client.AuthenticateAsync(_fromEmail, _appPassword);
        await client.SendAsync(message);
        await client.DisconnectAsync(true);
    }
}
