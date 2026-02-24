using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Auth.DTOs;

using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Auth.Commands;

public class MemberLoginCommand : IRequest<AuthResponse>
{
    public string Username { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}

public class MemberLoginCommandHandler : IRequestHandler<MemberLoginCommand, AuthResponse>
{
    private readonly IJwtService _jwtService;

    public MemberLoginCommandHandler(IJwtService jwtService)
    {
        _jwtService = jwtService;
    }

    public async Task<AuthResponse> Handle(MemberLoginCommand request, CancellationToken cancellationToken)
    {
        var response = await _jwtService.LoginAsync(new LoginRequest
        {
            Username = request.Username,
            Password = request.Password
        });

        if (string.Equals(response.Role, "Admin", StringComparison.OrdinalIgnoreCase))
        {
            throw new UnauthorizedAccessException("Administratori koriste desktop aplikaciju.");
        }

        return response;
    }
}

public class MemberLoginCommandValidator : AbstractValidator<MemberLoginCommand>
{
    public MemberLoginCommandValidator()
    {
        RuleFor(x => x.Username)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MinimumLength(3).WithMessage("{PropertyName} mora imati najmanje 3 karaktera.")
            .MaximumLength(50).WithMessage("{PropertyName} ne smije imati vise od 50 karaktera.");

        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MinimumLength(6).WithMessage("{PropertyName} mora imati najmanje 6 karaktera.")
            .MaximumLength(100).WithMessage("{PropertyName} ne smije imati vise od 100 karaktera.");
    }
}

