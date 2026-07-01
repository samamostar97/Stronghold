namespace Stronghold.Application.Exceptions;

// Trazeni zapis ne postoji - mapira se na HTTP 404.
public class NotFoundException : Exception
{
    public NotFoundException(string message) : base(message)
    {
    }
}
