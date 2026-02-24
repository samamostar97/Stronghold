using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Exceptions;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.Trainers.Commands;

public class BookTrainerAppointmentCommand : IRequest<AppointmentResponse>
{
    public int TrainerId { get; set; }
    public DateTime Date { get; set; }
}

public class BookTrainerAppointmentCommandHandler : IRequestHandler<BookTrainerAppointmentCommand, AppointmentResponse>
{
    private readonly ITrainerRepository _trainerRepository;
    private readonly ICurrentUserService _currentUserService;

    public BookTrainerAppointmentCommandHandler(ITrainerRepository trainerRepository, ICurrentUserService currentUserService)
    {
        _trainerRepository = trainerRepository;
        _currentUserService = currentUserService;
    }

    public async Task<AppointmentResponse> Handle(BookTrainerAppointmentCommand request, CancellationToken cancellationToken)
    {
        EnsureGymMemberAccess();

        var normalizedDate = NormalizeAndValidateAppointmentDate(request.Date);

        var trainer = await _trainerRepository.GetByIdAsync(request.TrainerId, cancellationToken);
        if (trainer is null)
        {
            throw new KeyNotFoundException("Trener ne postoji.");
        }

        var userId = _currentUserService.UserId!.Value;

        var userHasAppointment = await _trainerRepository.UserHasAppointmentOnDateAsync(userId, normalizedDate, cancellationToken);
        if (userHasAppointment)
        {
            throw new ConflictException("Korisnik vec ima termin na ovaj datum.");
        }

        var slotStart = normalizedDate;
        var slotEnd = normalizedDate.AddHours(1);
        var isTrainerBusy = await _trainerRepository.IsBusyInSlotAsync(request.TrainerId, slotStart, slotEnd, cancellationToken);
        if (isTrainerBusy)
        {
            throw new InvalidOperationException("Odabrani trener je zauzet u ovom terminu.");
        }

        var appointment = new Appointment
        {
            UserId = userId,
            TrainerId = request.TrainerId,
            AppointmentDate = normalizedDate
        };

        await _trainerRepository.AddAppointmentAsync(appointment, cancellationToken);

        return new AppointmentResponse
        {
            Id = appointment.Id,
            TrainerName = trainer.FirstName + " " + trainer.LastName,
            AppointmentDate = appointment.AppointmentDate
        };
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

    private static DateTime NormalizeAndValidateAppointmentDate(DateTime date)
    {
        var localDate = StrongholdTimeUtils.ToLocal(date);

        if (localDate < StrongholdTimeUtils.LocalNow)
        {
            throw new ArgumentException("Nemoguce unijeti datum u proslosti");
        }

        if (localDate.Date == StrongholdTimeUtils.LocalToday)
        {
            throw new ArgumentException("Nemoguce napraviti termin na isti dan");
        }

        if (localDate.Hour < 9 || localDate.Hour >= 17)
        {
            throw new ArgumentException("Termini su moguci samo izmedju 9:00 i 17:00");
        }

        if (localDate.Minute != 0 || localDate.Second != 0 || localDate.Millisecond != 0)
        {
            throw new ArgumentException("Termin mora biti unesen na puni sat.");
        }

        return new DateTime(localDate.Year, localDate.Month, localDate.Day, localDate.Hour, 0, 0, localDate.Kind);
    }
}

public class BookTrainerAppointmentCommandValidator : AbstractValidator<BookTrainerAppointmentCommand>
{
    public BookTrainerAppointmentCommandValidator()
    {
        RuleFor(x => x.TrainerId)
            .GreaterThan(0);

        RuleFor(x => x.Date)
            .NotEmpty();
    }
}
