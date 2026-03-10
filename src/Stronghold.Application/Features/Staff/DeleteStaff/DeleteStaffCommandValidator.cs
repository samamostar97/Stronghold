using FluentValidation;

namespace Stronghold.Application.Features.Staff.DeleteStaff;

public class DeleteStaffCommandValidator : AbstractValidator<DeleteStaffCommand>
{
    public DeleteStaffCommandValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0).WithMessage("ID osoblja je obavezan.");
    }
}
