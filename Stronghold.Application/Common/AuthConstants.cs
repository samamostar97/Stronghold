namespace Stronghold.Application.Common;

/// <summary>
/// Issuer i audience nisu tajne ni environment-specificne vrijednosti pa stoje u kodu;
/// tajni kljuc (JWT_KEY) dolazi iskljucivo iz environment varijable.
/// </summary>
public static class AuthConstants
{
    public const string Issuer = "Stronghold.API";
    public const string Audience = "Stronghold.Clients";
    public const int AccessTokenMinutes = 15;
    public const int RefreshTokenDays = 7;
}
