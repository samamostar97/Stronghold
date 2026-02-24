using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Auth.DTOs;
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
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .EmailAddress().WithMessage("Unesite ispravnu email adresu.")
            .MinimumLength(5).WithMessage("{PropertyName} mora imati najmanje 5 karaktera.")
            .MaximumLength(255).WithMessage("{PropertyName} ne smije imati vise od 255 karaktera.");

        RuleFor(x => x.Code)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .Matches(@"^\d{6}$").WithMessage("{PropertyName} nije u ispravnom formatu.");

        RuleFor(x => x.NewPassword)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MinimumLength(6).WithMessage("{PropertyName} mora imati najmanje 6 karaktera.")
            .MaximumLength(100).WithMessage("{PropertyName} ne smije imati vise od 100 karaktera.");
    }
}

