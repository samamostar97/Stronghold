using FluentValidation;
using MediatR;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Auth.Commands;

public class ResetPasswordCommand : IRequest<Unit>
{
    public string Email { get; set; } = string.Empty;
    public string Code { get; set; } = string.Empty;
    public string NewPassword { get; set; } = string.Empty;
}

public class ResetPasswordCommandHandler : IRequestHandler<ResetPasswordCommand, Unit>
{
    private readonly IJwtService _jwtService;

    public ResetPasswordCommandHandler(IJwtService jwtService)
    {
        _jwtService = jwtService;
    }

    public async Task<Unit> Handle(ResetPasswordCommand request, CancellationToken cancellationToken)
    {
        await _jwtService.ResetPasswordAsync(new ResetPasswordRequest
        {
            Email = request.Email,
            Code = request.Code,
            NewPassword = request.NewPassword
        });

        return Unit.Value;
    }
}

public class ResetPasswordCommandValidator : AbstractValidator<ResetPasswordCommand>
{
    public ResetPasswordCommandValidator()
    {
        RuleFor(x => x.Email)
            .NotEmpty()
            .EmailAddress()
            .MinimumLength(5)
            .MaximumLength(255);

        RuleFor(x => x.Code)
            .NotEmpty()
            .Matches(@"^\d{6}$");

        RuleFor(x => x.NewPassword)
            .NotEmpty()
            .MinimumLength(6)
            .MaximumLength(100);
    }
}
