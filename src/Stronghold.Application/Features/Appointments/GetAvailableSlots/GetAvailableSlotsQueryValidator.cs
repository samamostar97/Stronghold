using FluentValidation;

namespace Stronghold.Application.Features.Appointments.GetAvailableSlots;

public class GetAvailableSlotsQueryValidator : AbstractValidator<GetAvailableSlotsQuery>
{
    public GetAvailableSlotsQueryValidator()
    {
        RuleFor(x => x.StaffId)
            .GreaterThan(0).WithMessage("ID osoblja je obavezan.");

        RuleFor(x => x.Date)
            .NotEmpty().WithMessage("Datum je obavezan.");
    }
}
