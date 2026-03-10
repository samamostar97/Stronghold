using FluentValidation;

namespace Stronghold.Application.Features.Users.DeleteUser;

public class DeleteUserCommandValidator : AbstractValidator<DeleteUserCommand>
{
    public DeleteUserCommandValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0).WithMessage("ID korisnika je obavezan.");
    }
}
