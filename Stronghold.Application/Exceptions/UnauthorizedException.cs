namespace Stronghold.Application.Exceptions;

/// <summary>
/// Nevazeci kredencijali ili istekli/revokirani token - mapira se na HTTP 401.
/// </summary>
public class UnauthorizedException : Exception
{
    public UnauthorizedException(string message) : base(message)
    {
    }
}
