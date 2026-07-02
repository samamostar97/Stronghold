namespace Stronghold.Application.Interfaces;

/// <summary>
/// Id trenutno prijavljenog korisnika iz JWT tokena - userId se nikad ne prima
/// iz rute ili body-ja za operacije nad vlastitim podacima.
/// </summary>
public interface ICurrentUserService
{
    int UserId { get; }
    bool IsAdmin { get; }
}
