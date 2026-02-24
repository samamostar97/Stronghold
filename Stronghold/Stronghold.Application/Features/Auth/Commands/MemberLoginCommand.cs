using FluentValidation;
using MediatR;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
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
            .NotEmpty()
            .MinimumLength(3)
            .MaximumLength(50);

        RuleFor(x => x.Password)
            .NotEmpty()
            .MinimumLength(6)
            .MaximumLength(100);
    }
}
