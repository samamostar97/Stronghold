namespace Stronghold.Application.Exceptions;

/// <summary>
/// Trazeni zapis ne postoji - mapira se na HTTP 404.
/// </summary>
public class NotFoundException : Exception
{
    public NotFoundException(string message) : base(message)
    {
    }
}
