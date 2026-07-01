namespace Stronghold.Application.Exceptions;

// Krsenje poslovnog pravila - mapira se na HTTP 400 sa porukom za korisnika.
public class BusinessException : Exception
{
    public BusinessException(string message) : base(message)
    {
    }
}
