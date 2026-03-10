using FluentValidation;

namespace Stronghold.Application.Features.Users.UpdateProfileImage;

public class UpdateProfileImageCommandValidator : AbstractValidator<UpdateProfileImageCommand>
{
    private static readonly string[] AllowedExtensions = { ".jpg", ".jpeg", ".png", ".webp" };

    public UpdateProfileImageCommandValidator()
    {
        RuleFor(x => x.FileName)
            .NotEmpty().WithMessage("Naziv fajla je obavezan.")
            .Must(name => AllowedExtensions.Contains(Path.GetExtension(name).ToLower()))
            .WithMessage("Dozvoljeni formati su: .jpg, .jpeg, .png, .webp");
    }
}
