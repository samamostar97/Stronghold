using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Auth.DTOs;

using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Auth.Commands;

public class RegisterCommand : IRequest<AuthResponse>
{
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string Username { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}

public class RegisterCommandHandler : IRequestHandler<RegisterCommand, AuthResponse>
{
    private readonly IJwtService _jwtService;

    public RegisterCommandHandler(IJwtService jwtService)
    {
        _jwtService = jwtService;
    }

    public async Task<AuthResponse> Handle(RegisterCommand request, CancellationToken cancellationToken)
    {
        var response = await _jwtService.RegisterAsync(new RegisterRequest
        {
            FirstName = request.FirstName,
            LastName = request.LastName,
            Username = request.Username,
            Email = request.Email,
            PhoneNumber = request.PhoneNumber,
            Password = request.Password
        });

        return response ?? throw new InvalidOperationException("Registracija nije uspjela.");
    }
}

public class RegisterCommandValidator : AbstractValidator<RegisterCommand>
{
    public RegisterCommandValidator()
    {
        RuleFor(x => x.FirstName)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MinimumLength(2).WithMessage("{PropertyName} mora imati najmanje 2 karaktera.")
            .MaximumLength(100).WithMessage("{PropertyName} ne smije imati vise od 100 karaktera.");

        RuleFor(x => x.LastName)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MinimumLength(2).WithMessage("{PropertyName} mora imati najmanje 2 karaktera.")
            .MaximumLength(100).WithMessage("{PropertyName} ne smije imati vise od 100 karaktera.");

        RuleFor(x => x.Username)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MinimumLength(3).WithMessage("{PropertyName} mora imati najmanje 3 karaktera.")
            .MaximumLength(50).WithMessage("{PropertyName} ne smije imati vise od 50 karaktera.");

        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .EmailAddress().WithMessage("Unesite ispravnu email adresu.")
            .MinimumLength(5).WithMessage("{PropertyName} mora imati najmanje 5 karaktera.")
            .MaximumLength(255).WithMessage("{PropertyName} ne smije imati vise od 255 karaktera.");

        RuleFor(x => x.PhoneNumber)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MinimumLength(9).WithMessage("{PropertyName} mora imati najmanje 9 karaktera.")
            .MaximumLength(20).WithMessage("{PropertyName} ne smije imati vise od 20 karaktera.")
            .Matches(@"^(\+387|387|0)?\s?6\d([-\s]?\d){6,7}$")
            .WithMessage("Broj telefona mora biti u formatu 061 123 456 ili +387 61 123 456.");

        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MinimumLength(6).WithMessage("{PropertyName} mora imati najmanje 6 karaktera.")
            .MaximumLength(100).WithMessage("{PropertyName} ne smije imati vise od 100 karaktera.");
    }
}


