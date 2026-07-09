namespace Stronghold.Core.Enums;

/// <summary>
/// Narudzba nastaje tek nakon uspjesnog placanja, pa je pocetni status Processing (u obradi).
/// Dozvoljeni prelazi: Processing -> Shipped -> Delivered; otkazivanje uz Stripe refund
/// iz Processing (kupac ili admin) i Shipped (samo admin).
/// Shipped = 3 jer su ranije vrijednosti vec pohranjene u bazi.
/// </summary>
public enum OrderStatus
{
    Processing = 0,
    Delivered = 1,
    Cancelled = 2,
    Shipped = 3
}
