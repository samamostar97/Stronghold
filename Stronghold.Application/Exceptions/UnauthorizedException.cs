namespace Stronghold.Application.Exceptions;

// Nevazeci kredencijali ili istekli/revokirani token - mapira se na HTTP 401.
public class UnauthorizedException : Exception
{
    public UnauthorizedException(string message) : base(message)
    {
    }
}
