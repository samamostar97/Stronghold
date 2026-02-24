using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Auth.DTOs;
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
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .EmailAddress().WithMessage("Unesite ispravnu email adresu.")
            .MinimumLength(5).WithMessage("{PropertyName} mora imati najmanje 5 karaktera.")
            .MaximumLength(255).WithMessage("{PropertyName} ne smije imati vise od 255 karaktera.");
    }
}

