using FluentValidation;
using MediatR;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Auth.Commands;

public class ForgotPasswordCommand : IRequest<Unit>
{
    public string Email { get; set; } = string.Empty;
}

public class ForgotPasswordCommandHandler : IRequestHandler<ForgotPasswordCommand, Unit>
{
    private readonly IJwtService _jwtService;

    public ForgotPasswordCommandHandler(IJwtService jwtService)
    {
        _jwtService = jwtService;
    }

    public async Task<Unit> Handle(ForgotPasswordCommand request, CancellationToken cancellationToken)
    {
        await _jwtService.ForgotPasswordAsync(new ForgotPasswordRequest
        {
            Email = request.Email
        });

        return Unit.Value;
    }
}

public class ForgotPasswordCommandValidator : AbstractValidator<ForgotPasswordCommand>
{
    public ForgotPasswordCommandValidator()
    {
        RuleFor(x => x.Email)
            .NotEmpty()
            .EmailAddress()
            .MinimumLength(5)
            .MaximumLength(255);
    }
}
