namespace Stronghold.Application.Common;

// Issuer i audience su fiksne vrijednosti aplikacije; tajni kljuc (JWT_KEY)
// dolazi iz environment varijable.
public static class AuthConstants
{
    public const string Issuer = "Stronghold.API";
    public const string Audience = "Stronghold.Clients";
    public const int AccessTokenMinutes = 15;
    public const int RefreshTokenDays = 7;
}
