using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Trainers.Queries;

public class GetTrainerAvailableHoursQuery : IRequest<IReadOnlyList<int>>
{
    public int TrainerId { get; set; }
    public DateTime Date { get; set; }
}

public class GetTrainerAvailableHoursQueryHandler : IRequestHandler<GetTrainerAvailableHoursQuery, IReadOnlyList<int>>
{
    private readonly ITrainerRepository _trainerRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetTrainerAvailableHoursQueryHandler(ITrainerRepository trainerRepository, ICurrentUserService currentUserService)
    {
        _trainerRepository = trainerRepository;
        _currentUserService = currentUserService;
    }

    public async Task<IReadOnlyList<int>> Handle(GetTrainerAvailableHoursQuery request, CancellationToken cancellationToken)
    {
        EnsureGymMemberAccess();

        const int workStartHour = 9;
        const int workEndHour = 17;

        var localDate = StrongholdTimeUtils.ToLocal(request.Date);
        var targetDate = localDate.Date;
        if (targetDate <= StrongholdTimeUtils.LocalToday)
        {
            return Array.Empty<int>();
        }

        var appointments = await _trainerRepository.GetAppointmentTimesForDateAsync(request.TrainerId, targetDate, cancellationToken);

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

    private void EnsureGymMemberAccess()
    {
        if (!_currentUserService.IsAuthenticated || _currentUserService.UserId is null)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }

        if (!_currentUserService.IsInRole("GymMember"))
        {
            throw new UnauthorizedAccessException("Nemate dozvolu za ovu akciju.");
        }
    }
}

public class GetTrainerAvailableHoursQueryValidator : AbstractValidator<GetTrainerAvailableHoursQuery>
{
    public GetTrainerAvailableHoursQueryValidator()
    {
        RuleFor(x => x.TrainerId)
            .GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");

        RuleFor(x => x.Date)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.");
    }
}

