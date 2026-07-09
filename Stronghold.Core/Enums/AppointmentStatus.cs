namespace Stronghold.Core.Enums;

/// <summary>
/// Dozvoljeni prelazi: Pending -> Confirmed -> Completed, Pending/Confirmed -> Cancelled.
/// </summary>
public enum AppointmentStatus
{
    Pending = 0,
    Confirmed = 1,
    Completed = 2,
    Cancelled = 3
}
