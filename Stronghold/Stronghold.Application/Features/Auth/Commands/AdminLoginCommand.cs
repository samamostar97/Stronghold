using FluentValidation;
using MediatR;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Auth.Commands;

public class AdminLoginCommand : IRequest<AuthResponse>
{
    public string Username { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}

public class AdminLoginCommandHandler : IRequestHandler<AdminLoginCommand, AuthResponse>
{
    private readonly IJwtService _jwtService;

    public AdminLoginCommandHandler(IJwtService jwtService)
    {
        _jwtService = jwtService;
    }

    public async Task<AuthResponse> Handle(AdminLoginCommand request, CancellationToken cancellationToken)
    {
        var response = await _jwtService.LoginAsync(new LoginRequest
        {
            Username = request.Username,
            Password = request.Password
        });

        if (!string.Equals(response.Role, "Admin", StringComparison.OrdinalIgnoreCase))
        {
            throw new UnauthorizedAccessException("Pristup odbijen.");
        }

        return response;
    }
}

public class AdminLoginCommandValidator : AbstractValidator<AdminLoginCommand>
{
    public AdminLoginCommandValidator()
    {
        RuleFor(x => x.Username)
            .NotEmpty()
            .MinimumLength(3)
            .MaximumLength(50);

        RuleFor(x => x.Password)
            .NotEmpty()
            .MaximumLength(100);
    }
}
