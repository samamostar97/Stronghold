namespace Stronghold.Core;

/// <summary>
/// Nazivi rola za [Authorize(Roles = ...)] i JWT claimove - bez magic stringova.
/// </summary>
public static class Roles
{
    public const string Admin = "Admin";
    public const string GymMember = "GymMember";
}
