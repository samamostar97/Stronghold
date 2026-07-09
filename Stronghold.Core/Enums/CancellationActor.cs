namespace Stronghold.Core.Enums;

public enum CancellationActor
{
    User = 0,
    Admin = 1,
    // Automatika (pending termin kojem je prosao datum bez potvrde).
    System = 2
}
