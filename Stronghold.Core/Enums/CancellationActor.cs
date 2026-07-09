namespace Stronghold.Core.Enums;

public enum CancellationActor
{
    User = 0,
    Admin = 1,
    /// <summary>Automatika (pending termin kojem je prosao datum bez potvrde).</summary>
    System = 2
}
