using FluentValidation;
using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Seminars.CreateSeminar;

[AuthorizeRole("Admin")]
public class CreateSeminarCommand : IRequest<SeminarResponse>
{
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Lecturer { get; set; } = string.Empty;
    public DateTime StartDate { get; set; }
    public int MaxCapacity { get; set; }
}

public class CreateSeminarCommandValidator : AbstractValidator<CreateSeminarCommand>
{
    public CreateSeminarCommandValidator()
    {
        RuleFor(x => x.Name).NotEmpty().WithMessage("Naziv je obavezan.");
        RuleFor(x => x.Lecturer).NotEmpty().WithMessage("Predavac je obavezan.");
        RuleFor(x => x.StartDate).GreaterThan(DateTime.UtcNow).WithMessage("Datum seminara mora biti u buducnosti.");
        RuleFor(x => x.MaxCapacity).GreaterThan(0).WithMessage("Kapacitet mora biti veci od 0.");
    }
}
