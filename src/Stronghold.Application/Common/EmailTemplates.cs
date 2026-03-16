using Stronghold.Messaging;

namespace Stronghold.Application.Common;

public static class EmailTemplates
{
    public static EmailMessage Welcome(string email, string firstName) => new()
    {
        To = email,
        Subject = "Dobrodosli u Stronghold!",
        Body = $@"
            <h2>Dobrodosli, {firstName}!</h2>
            <p>Hvala vam sto ste se registrovali na Stronghold platformu.</p>
            <p>Zelimo vam ugodno koristenje nasih usluga!</p>
            <br/><p>Stronghold Tim</p>"
    };

    public static EmailMessage OrderConfirmed(string email, string firstName, int orderId, decimal totalAmount) => new()
    {
        To = email,
        Subject = $"Potvrda narudzbe #{orderId}",
        Body = $@"
            <h2>Postovani {firstName},</h2>
            <p>Vasa narudzba <strong>#{orderId}</strong> je uspjesno potvrđena.</p>
            <p>Ukupan iznos: <strong>{totalAmount:F2} KM</strong></p>
            <p>Hvala vam na kupovini!</p>
            <br/><p>Stronghold Tim</p>"
    };

    public static EmailMessage OrderShipped(string email, string firstName, int orderId) => new()
    {
        To = email,
        Subject = $"Narudzba #{orderId} je poslana na dostavu",
        Body = $@"
            <h2>Postovani {firstName},</h2>
            <p>Vasa narudzba <strong>#{orderId}</strong> je poslana na dostavu.</p>
            <p>Ocekujte isporuku u najkracem mogucem roku.</p>
            <br/><p>Stronghold Tim</p>"
    };

    public static EmailMessage AppointmentApproved(string email, string firstName, string staffName, DateTime scheduledAt) => new()
    {
        To = email,
        Subject = "Vas termin je odobren",
        Body = $@"
            <h2>Postovani {firstName},</h2>
            <p>Vas termin sa <strong>{staffName}</strong> je odobren.</p>
            <p>Datum i vrijeme: <strong>{scheduledAt:dd.MM.yyyy HH:mm}</strong></p>
            <p>Vidimo se!</p>
            <br/><p>Stronghold Tim</p>"
    };

    public static EmailMessage AppointmentRejected(string email, string firstName, string staffName, DateTime scheduledAt) => new()
    {
        To = email,
        Subject = "Vas termin je odbijen",
        Body = $@"
            <h2>Postovani {firstName},</h2>
            <p>Nazalost, vas termin sa <strong>{staffName}</strong> zakazan za <strong>{scheduledAt:dd.MM.yyyy HH:mm}</strong> je odbijen.</p>
            <p>Molimo vas da zakazete novi termin u nekom drugom terminu.</p>
            <br/><p>Stronghold Tim</p>"
    };

    public static EmailMessage MembershipAssigned(string email, string firstName, string packageName, DateTime endDate) => new()
    {
        To = email,
        Subject = "Clanarina je aktivirana",
        Body = $@"
            <h2>Postovani {firstName},</h2>
            <p>Vasa clanarina <strong>{packageName}</strong> je uspjesno aktivirana.</p>
            <p>Clanarina istice: <strong>{endDate:dd.MM.yyyy}</strong></p>
            <p>Zelimo vam uspjesne treninge!</p>
            <br/><p>Stronghold Tim</p>"
    };

    public static EmailMessage MembershipExpired(string email, string firstName, string packageName) => new()
    {
        To = email,
        Subject = "Vasa clanarina je istekla",
        Body = $@"
            <h2>Postovani {firstName},</h2>
            <p>Vasa clanarina <strong>{packageName}</strong> je istekla.</p>
            <p>Za nastavak koristenja usluga, obratite se nasem osoblju za obnovu clanarine.</p>
            <br/><p>Stronghold Tim</p>"
    };

    public static EmailMessage AppointmentExpired(string email, string firstName, string staffName, DateTime scheduledAt) => new()
    {
        To = email,
        Subject = "Vas termin je istekao",
        Body = $@"
            <h2>Postovani {firstName},</h2>
            <p>Vas termin sa <strong>{staffName}</strong> na datum <strong>{scheduledAt:dd.MM.yyyy HH:mm}</strong> nije odobren i istekao je.</p>
            <p>Molimo vas da zakazete novi termin.</p>
            <br/><p>Stronghold Tim</p>"
    };

    public static EmailMessage LevelUp(string email, string firstName, string levelName) => new()
    {
        To = email,
        Subject = "Cestitamo - novi level!",
        Body = $@"
            <h2>Cestitamo, {firstName}!</h2>
            <p>Dostigli ste <strong>{levelName}</strong>!</p>
            <p>Nastavite sa treninzima i ostvarujte jos vise!</p>
            <br/><p>Stronghold Tim</p>"
    };
}
