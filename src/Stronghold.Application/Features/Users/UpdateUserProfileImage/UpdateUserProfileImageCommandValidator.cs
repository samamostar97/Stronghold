using FluentValidation;

namespace Stronghold.Application.Features.Users.UpdateUserProfileImage;

public class UpdateUserProfileImageCommandValidator : AbstractValidator<UpdateUserProfileImageCommand>
{
    private static readonly string[] AllowedExtensions = { ".jpg", ".jpeg", ".png", ".webp" };

    public UpdateUserProfileImageCommandValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0).WithMessage("ID korisnika je obavezan.");

        RuleFor(x => x.FileName)
            .NotEmpty().WithMessage("Naziv fajla je obavezan.")
            .Must(name => AllowedExtensions.Contains(Path.GetExtension(name).ToLower()))
            .WithMessage("Dozvoljeni formati su: .jpg, .jpeg, .png, .webp");
    }
}
