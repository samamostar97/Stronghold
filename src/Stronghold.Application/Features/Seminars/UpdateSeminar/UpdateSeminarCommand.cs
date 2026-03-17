using FluentValidation;
using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Seminars.UpdateSeminar;

[AuthorizeRole("Admin")]
public class UpdateSeminarCommand : IRequest<SeminarResponse>
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Lecturer { get; set; } = string.Empty;
    public DateTime StartDate { get; set; }
    public int MaxCapacity { get; set; }
}

public class UpdateSeminarCommandValidator : AbstractValidator<UpdateSeminarCommand>
{
    public UpdateSeminarCommandValidator()
    {
        RuleFor(x => x.Name).NotEmpty().WithMessage("Naziv je obavezan.");
        RuleFor(x => x.Lecturer).NotEmpty().WithMessage("Predavac je obavezan.");
        RuleFor(x => x.MaxCapacity).GreaterThan(0).WithMessage("Kapacitet mora biti veci od 0.");
    }
}
