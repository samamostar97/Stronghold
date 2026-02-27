using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Services;

public class OrderEmailService : IOrderEmailService
{
    private readonly IEmailService _emailService;

    public OrderEmailService(IEmailService emailService)
    {
        _emailService = emailService;
    }

    public async Task SendOrderConfirmationAsync(
        User user,
        Order order,
        IReadOnlyList<OrderItem> orderItems,
        IReadOnlyList<Supplement> supplements)
    {
        var itemsList = string.Join(
            "",
            orderItems.Select(x =>
            {
                var supplement = supplements.First(s => s.Id == x.SupplementId);
                return $"<li>{supplement.Name} x{x.Quantity} - {x.UnitPrice:F2} KM</li>";
            }));

        var emailBody = $@"
                <html>
                <body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>
                    <h2 style='color: #e63946;'>Potvrda narudzbe #{order.Id}</h2>
                    <p>Postovani/a {user.FirstName},</p>
                    <p>Vasa uplata je uspjesno primljena. Hvala Vam na povjerenju.</p>

                    <div style='background-color: #f8f9fa; padding: 15px; border-radius: 8px; margin: 20px 0;'>
                        <p style='margin: 0; font-size: 16px;'>
                            <strong>Skladiste je zaprimilo Vasu narudzbu.</strong><br/>
                            Paket se priprema za dostavu.
                        </p>
                    </div>

                    <h3>Detalji narudzbe:</h3>
                    <ul>{itemsList}</ul>
                    <p><strong>Ukupan iznos: {order.TotalAmount:F2} KM</strong></p>
                    <p><strong>Datum narudzbe:</strong> {order.PurchaseDate:dd.MM.yyyy HH:mm}</p>

                    <hr style='border: none; border-top: 1px solid #ddd; margin: 20px 0;'/>
                    <p style='color: #666; font-size: 14px;'>
                        Obavijesticemo Vas kada narudzba bude poslana.
                    </p>
                    <p>Srdacan pozdrav,<br/><strong>Stronghold Tim</strong></p>
                </body>
                </html>";

        await _emailService.SendEmailAsync(
            user.Email,
            $"Potvrda narudzbe #{order.Id} - uplata primljena",
            emailBody);
    }
}
