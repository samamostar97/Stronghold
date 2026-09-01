namespace Stronghold.Core.Enums;

// Narudzba se snima kao PendingPayment prije Stripe naplate (zakljucane stavke i cijene),
// a potvrdom placanja prelazi u Processing. Dozvoljeni prelazi:
// PendingPayment -> Processing -> Shipped -> Delivered; otkazivanje uz Stripe refund
// iz Processing i Shipped (samo admin). PendingPayment zapisi se ne mijesaju s pravim
// narudzbama; administrator ih vidi samo kroz eksplicitni filter statusa.
// Shipped = 3 jer su ranije vrijednosti vec pohranjene u bazi.
public enum OrderStatus
{
    Processing = 0,
    Delivered = 1,
    Cancelled = 2,
    Shipped = 3,
    PendingPayment = 4
}
