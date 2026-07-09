namespace Stronghold.Core.Enums;

// Dozvoljeni prelazi: Pending -> Confirmed -> Completed, Pending/Confirmed -> Cancelled,
// Confirmed -> NoShow (samo kad je termin vec prosao).
public enum AppointmentStatus
{
    Pending = 0,
    Confirmed = 1,
    Completed = 2,
    Cancelled = 3,
    NoShow = 4
}
