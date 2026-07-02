namespace Stronghold.Application.Exceptions;

/// <summary>
/// Krsenje poslovnog pravila - mapira se na HTTP 400 sa porukom za korisnika.
/// </summary>
public class BusinessException : Exception
{
    public BusinessException(string message) : base(message)
    {
    }
}
