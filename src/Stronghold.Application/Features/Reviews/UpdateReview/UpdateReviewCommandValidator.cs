using FluentValidation;

namespace Stronghold.Application.Features.Reviews.UpdateReview;

public class UpdateReviewCommandValidator : AbstractValidator<UpdateReviewCommand>
{
    public UpdateReviewCommandValidator()
    {
        RuleFor(x => x.Rating)
            .InclusiveBetween(1, 5)
            .WithMessage("Ocjena mora biti između 1 i 5.");

        RuleFor(x => x.Comment)
            .MaximumLength(1000).WithMessage("Komentar ne može biti duži od 1000 karaktera.");
    }
}
