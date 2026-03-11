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

    public async Task SendWelcomeAsync(string email, string firstName)
    {
        var subject = "Dobrodosli u Stronghold!";
        var body = $@"
            <h2>Dobrodosli, {firstName}!</h2>
            <p>Hvala vam sto ste se registrovali na Stronghold platformu.</p>
            <p>Zelimo vam ugodno koristenje nasih usluga!</p>
            <br/>
            <p>Stronghold Tim</p>";

        await SendEmailAsync(email, subject, body);
    }

    public async Task SendOrderConfirmedAsync(string email, string firstName, int orderId, decimal totalAmount)
    {
        var subject = $"Potvrda narudzbe #{orderId}";
        var body = $@"
            <h2>Postovani {firstName},</h2>
            <p>Vasa narudzba <strong>#{orderId}</strong> je uspjesno potvrđena.</p>
            <p>Ukupan iznos: <strong>{totalAmount:F2} KM</strong></p>
            <p>Hvala vam na kupovini!</p>
            <br/>
            <p>Stronghold Tim</p>";

        await SendEmailAsync(email, subject, body);
    }

    public async Task SendOrderShippedAsync(string email, string firstName, int orderId)
    {
        var subject = $"Narudzba #{orderId} je poslana na dostavu";
        var body = $@"
            <h2>Postovani {firstName},</h2>
            <p>Vasa narudzba <strong>#{orderId}</strong> je poslana na dostavu.</p>
            <p>Ocekujte isporuku u najkracem mogucem roku.</p>
            <br/>
            <p>Stronghold Tim</p>";

        await SendEmailAsync(email, subject, body);
    }

    public async Task SendAppointmentApprovedAsync(string email, string firstName, string staffName, DateTime scheduledAt)
    {
        var subject = "Vas termin je odobren";
        var body = $@"
            <h2>Postovani {firstName},</h2>
            <p>Vas termin sa <strong>{staffName}</strong> je odobren.</p>
            <p>Datum i vrijeme: <strong>{scheduledAt:dd.MM.yyyy HH:mm}</strong></p>
            <p>Vidimo se!</p>
            <br/>
            <p>Stronghold Tim</p>";

        await SendEmailAsync(email, subject, body);
    }

    public async Task SendAppointmentRejectedAsync(string email, string firstName, string staffName, DateTime scheduledAt)
    {
        var subject = "Vas termin je odbijen";
        var body = $@"
            <h2>Postovani {firstName},</h2>
            <p>Nazalost, vas termin sa <strong>{staffName}</strong> zakazan za <strong>{scheduledAt:dd.MM.yyyy HH:mm}</strong> je odbijen.</p>
            <p>Molimo vas da zakazete novi termin u nekom drugom terminu.</p>
            <br/>
            <p>Stronghold Tim</p>";

        await SendEmailAsync(email, subject, body);
    }

    public async Task SendMembershipAssignedAsync(string email, string firstName, string packageName, DateTime endDate)
    {
        var subject = "Clanarina je aktivirana";
        var body = $@"
            <h2>Postovani {firstName},</h2>
            <p>Vasa clanarina <strong>{packageName}</strong> je uspjesno aktivirana.</p>
            <p>Clanarina istice: <strong>{endDate:dd.MM.yyyy}</strong></p>
            <p>Zelimo vam uspjesne treninge!</p>
            <br/>
            <p>Stronghold Tim</p>";

        await SendEmailAsync(email, subject, body);
    }

    public async Task SendMembershipExpiredAsync(string email, string firstName, string packageName)
    {
        var subject = "Vasa clanarina je istekla";
        var body = $@"
            <h2>Postovani {firstName},</h2>
            <p>Vasa clanarina <strong>{packageName}</strong> je istekla.</p>
            <p>Za nastavak koristenja usluga, obratite se nasem osoblju za obnovu clanarini.</p>
            <br/>
            <p>Stronghold Tim</p>";

        await SendEmailAsync(email, subject, body);
    }

    public async Task SendAppointmentExpiredAsync(string email, string firstName, string staffName, DateTime scheduledAt)
    {
        var subject = "Vas termin je istekao";
        var body = $@"
            <h2>Postovani {firstName},</h2>
            <p>Vas termin sa <strong>{staffName}</strong> na datum <strong>{scheduledAt:dd.MM.yyyy HH:mm}</strong> nije odobren i istekao je.</p>
            <p>Molimo vas da zakazete novi termin.</p>
            <br/>
            <p>Stronghold Tim</p>";

        await SendEmailAsync(email, subject, body);
    }

    public async Task SendLevelUpAsync(string email, string firstName, string levelName)
    {
        var subject = "Cestitamo - novi level!";
        var body = $@"
            <h2>Cestitamo, {firstName}!</h2>
            <p>Dostigli ste <strong>{levelName}</strong>!</p>
            <p>Nastavite sa treninzima i ostvarujte jos vise!</p>
            <br/>
            <p>Stronghold Tim</p>";

        await SendEmailAsync(email, subject, body);
    }

    private async Task SendEmailAsync(string to, string subject, string htmlBody)
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
            // Log error in production - silently skip for now
        }
    }
}
