using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.IRepositories;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Nutritionists.Queries;

public class GetNutritionistAvailableHoursQuery : IRequest<IReadOnlyList<int>>, IAuthorizeGymMemberRequest
{
    public int NutritionistId { get; set; }

public DateTime Date { get; set; }
}

public class GetNutritionistAvailableHoursQueryHandler
    : IRequestHandler<GetNutritionistAvailableHoursQuery, IReadOnlyList<int>>
{
    private readonly INutritionistRepository _nutritionistRepository;

    public GetNutritionistAvailableHoursQueryHandler(
        INutritionistRepository nutritionistRepository)
    {
        _nutritionistRepository = nutritionistRepository;
    }

public async Task<IReadOnlyList<int>> Handle(
        GetNutritionistAvailableHoursQuery request,
        CancellationToken cancellationToken)
    {
        const int workStartHour = 9;
        const int workEndHour = 17;

        var localDate = StrongholdTimeUtils.ToLocal(request.Date);
        var targetDate = localDate.Date;
        if (targetDate <= StrongholdTimeUtils.LocalToday)
        {
            return Array.Empty<int>();
        }

        var appointments = await _nutritionistRepository.GetAppointmentTimesForDateAsync(
            request.NutritionistId,
            targetDate,
            cancellationToken);

        var availableHours = new List<int>();
        for (var hour = workStartHour; hour < workEndHour; hour++)
        {
            var slotStart = targetDate.AddHours(hour);
            var slotEnd = slotStart.AddHours(1);
            var isBusy = appointments.Any(x => x < slotEnd && x.AddHours(1) > slotStart);
            if (!isBusy)
            {
                availableHours.Add(hour);
            }
            }
        return availableHours;
    }
    }

public class GetNutritionistAvailableHoursQueryValidator : AbstractValidator<GetNutritionistAvailableHoursQuery>
{
    public GetNutritionistAvailableHoursQueryValidator()
    {
        RuleFor(x => x.NutritionistId)
            .GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");

        RuleFor(x => x.Date)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.");
    }
    }