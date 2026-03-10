using FluentValidation;

namespace Stronghold.Application.Features.Suppliers.DeleteSupplier;

public class DeleteSupplierCommandValidator : AbstractValidator<DeleteSupplierCommand>
{
    public DeleteSupplierCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("ID dobavljača je obavezan.");
    }
}
