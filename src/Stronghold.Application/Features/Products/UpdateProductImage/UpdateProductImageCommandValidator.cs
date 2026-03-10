using FluentValidation;

namespace Stronghold.Application.Features.Products.UpdateProductImage;

public class UpdateProductImageCommandValidator : AbstractValidator<UpdateProductImageCommand>
{
    public UpdateProductImageCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("ID proizvoda je obavezan.");

        RuleFor(x => x.FileStream)
            .NotNull().WithMessage("Slika je obavezna.");

        RuleFor(x => x.FileName)
            .NotEmpty().WithMessage("Naziv fajla je obavezan.");
    }
}
