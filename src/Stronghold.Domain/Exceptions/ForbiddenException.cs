namespace Stronghold.Domain.Exceptions;

public class ForbiddenException : Exception
{
    public ForbiddenException(string message = "Nemate pristup ovom resursu.") : base(message) { }
}
