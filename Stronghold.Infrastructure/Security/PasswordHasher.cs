using System.Security.Cryptography;

namespace Stronghold.Infrastructure.Security;

/// <summary>
/// PBKDF2 (Rfc2898) hashiranje lozinki - jedini hash format u aplikaciji,
/// koriste ga i seeder i auth servis.
/// </summary>
public static class PasswordHasher
{
    private const int SaltSize = 16;
    private const int HashSize = 32;
    private const int Iterations = 100_000;
    private static readonly HashAlgorithmName Algorithm = HashAlgorithmName.SHA256;

    public static string GenerateSalt()
    {
        return Convert.ToBase64String(RandomNumberGenerator.GetBytes(SaltSize));
    }

    public static string Hash(string password, string salt)
    {
        var saltBytes = Convert.FromBase64String(salt);
        var hash = Rfc2898DeriveBytes.Pbkdf2(password, saltBytes, Iterations, Algorithm, HashSize);
        return Convert.ToBase64String(hash);
    }

    public static bool Verify(string password, string salt, string expectedHash)
    {
        var actual = Convert.FromBase64String(Hash(password, salt));
        var expected = Convert.FromBase64String(expectedHash);
        return CryptographicOperations.FixedTimeEquals(actual, expected);
    }
}
