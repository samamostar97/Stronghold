using FluentValidation;
using MediatR;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Auth.Commands;

public class ChangePasswordCommand : IRequest<Unit>
{
    public string CurrentPassword { get; set; } = string.Empty;
    public string NewPassword { get; set; } = string.Empty;
}

public class ChangePasswordCommandHandler : IRequestHandler<ChangePasswordCommand, Unit>
{
    private readonly IJwtService _jwtService;
    private readonly ICurrentUserService _currentUserService;

    public ChangePasswordCommandHandler(IJwtService jwtService, ICurrentUserService currentUserService)
    {
        _jwtService = jwtService;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(ChangePasswordCommand request, CancellationToken cancellationToken)
    {
        var userId = EnsureAuthenticatedAccess();

        await _jwtService.ChangePasswordAsync(userId, new ChangePasswordRequest
        {
            CurrentPassword = request.CurrentPassword,
            NewPassword = request.NewPassword
        });

        return Unit.Value;
    }

    private int EnsureAuthenticatedAccess()
    {
        if (!_currentUserService.IsAuthenticated || _currentUserService.UserId is null)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }

        return _currentUserService.UserId.Value;
    }
}

public class ChangePasswordCommandValidator : AbstractValidator<ChangePasswordCommand>
{
    public ChangePasswordCommandValidator()
    {
        RuleFor(x => x.CurrentPassword)
            .NotEmpty()
            .MaximumLength(100);

        RuleFor(x => x.NewPassword)
            .NotEmpty()
            .MinimumLength(6)
            .MaximumLength(100);

        RuleFor(x => x)
            .Must(x => !string.Equals(x.CurrentPassword, x.NewPassword, StringComparison.Ordinal))
            .WithMessage("Nova lozinka mora biti razlicita od trenutne.");
    }
}
