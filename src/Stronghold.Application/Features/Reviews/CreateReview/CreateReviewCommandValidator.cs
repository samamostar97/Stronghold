using FluentValidation;

namespace Stronghold.Application.Features.Reviews.CreateReview;

public class CreateReviewCommandValidator : AbstractValidator<CreateReviewCommand>
{
    public CreateReviewCommandValidator()
    {
        RuleFor(x => x.Rating)
            .InclusiveBetween(1, 5)
            .WithMessage("Ocjena mora biti između 1 i 5.");

        RuleFor(x => x.ReviewType)
            .NotEmpty().WithMessage("Tip recenzije je obavezan.")
            .Must(x => x == "Product" || x == "Appointment")
            .WithMessage("Tip recenzije mora biti 'Product' ili 'Appointment'.");

        RuleFor(x => x.ProductId)
            .NotNull().When(x => x.ReviewType == "Product")
            .WithMessage("ProductId je obavezan za recenziju proizvoda.");

        RuleFor(x => x.AppointmentId)
            .NotNull().When(x => x.ReviewType == "Appointment")
            .WithMessage("AppointmentId je obavezan za recenziju termina.");

        RuleFor(x => x.Comment)
            .MaximumLength(1000).WithMessage("Komentar ne može biti duži od 1000 karaktera.");
    }
}
