namespace Stronghold.Application.Interfaces;

// Id trenutno prijavljenog korisnika iz JWT tokena - userId se nikad ne prima
// iz rute ili body-ja za operacije nad vlastitim podacima.
public interface ICurrentUserService
{
    int UserId { get; }
    bool IsAdmin { get; }
}
