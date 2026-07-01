namespace Stronghold.Core;

// Nazivi rola za [Authorize(Roles = ...)] i JWT claimove - bez magic stringova.
public static class Roles
{
    public const string Admin = "Admin";
    public const string GymMember = "GymMember";
}
