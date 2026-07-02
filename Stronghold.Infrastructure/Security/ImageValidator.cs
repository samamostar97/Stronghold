using Stronghold.Application.Exceptions;

namespace Stronghold.Infrastructure.Security;

/// <summary>
/// Validira upload slike po magic bytes (ne samo po ekstenziji/tvrdnji klijenta).
/// </summary>
public static class ImageValidator
{
    private const int MaxBytes = 2 * 1024 * 1024;

    public static byte[] DecodeAndValidate(string base64)
    {
        byte[] bytes;
        try
        {
            bytes = Convert.FromBase64String(base64);
        }
        catch (FormatException)
        {
            throw new BusinessException("Slika nije u validnom base64 formatu.");
        }

        if (bytes.Length > MaxBytes)
        {
            throw new BusinessException("Slika može imati najviše 2 MB.");
        }
        if (GetContentType(bytes) == null)
        {
            throw new BusinessException("Dozvoljeni formati slike su PNG i JPEG.");
        }
        return bytes;
    }

    public static string? GetContentType(byte[] bytes)
    {
        if (bytes.Length >= 8 &&
            bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47)
        {
            return "image/png";
        }
        if (bytes.Length >= 3 && bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF)
        {
            return "image/jpeg";
        }
        return null;
    }
}
