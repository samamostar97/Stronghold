using Stronghold.Application.IServices;

namespace Stronghold.TestServer;

public class FakeEmailService : IEmailService
{
    public Task SendEmailAsync(string toEmail, string subject, string body)
    {
        Console.WriteLine($"[FakeEmail] To: {toEmail} | Subject: {subject}");
        return Task.CompletedTask;
    }
}
