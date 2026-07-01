namespace Stronghold.Core.Enums;

// Narudzba nastaje tek nakon uspjesnog placanja, pa je pocetni status Processing (u obradi).
// Dozvoljeni prelazi: Processing -> Delivered, Processing -> Cancelled (uz Stripe refund).
public enum OrderStatus
{
    Processing = 0,
    Delivered = 1,
    Cancelled = 2
}
