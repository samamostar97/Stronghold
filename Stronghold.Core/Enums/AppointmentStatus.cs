namespace Stronghold.Core.Enums;

// Dozvoljeni prelazi: Pending -> Confirmed -> Completed, Pending/Confirmed -> Cancelled.
public enum AppointmentStatus
{
    Pending = 0,
    Confirmed = 1,
    Completed = 2,
    Cancelled = 3
}
