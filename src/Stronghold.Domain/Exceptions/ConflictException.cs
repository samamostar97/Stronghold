namespace Stronghold.Domain.Exceptions;

public class ConflictException : Exception
{
    public Dictionary<string, string> FieldErrors { get; } = new();

    public ConflictException(string message) : base(message) { }

    public ConflictException(Dictionary<string, string> fieldErrors)
        : base(string.Join(" ", fieldErrors.Values))
    {
        FieldErrors = fieldErrors;
    }
}
