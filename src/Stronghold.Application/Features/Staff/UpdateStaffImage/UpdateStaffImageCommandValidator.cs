using FluentValidation;

namespace Stronghold.Application.Features.Staff.UpdateStaffImage;

public class UpdateStaffImageCommandValidator : AbstractValidator<UpdateStaffImageCommand>
{
    private static readonly string[] AllowedExtensions = { ".jpg", ".jpeg", ".png", ".webp" };

    public UpdateStaffImageCommandValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0).WithMessage("ID osoblja je obavezan.");

        RuleFor(x => x.FileName)
            .NotEmpty().WithMessage("Naziv fajla je obavezan.")
            .Must(name => AllowedExtensions.Contains(Path.GetExtension(name).ToLower()))
            .WithMessage("Dozvoljeni formati su: .jpg, .jpeg, .png, .webp");
    }
}
