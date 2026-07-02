namespace Stronghold.Core.Enums;

/// <summary>
/// Narudzba nastaje tek nakon uspjesnog placanja, pa je pocetni status Processing (u obradi).
/// Dozvoljeni prelazi: Processing -> Delivered, Processing -> Cancelled (uz Stripe refund).
/// </summary>
public enum OrderStatus
{
    Processing = 0,
    Delivered = 1,
    Cancelled = 2
}
