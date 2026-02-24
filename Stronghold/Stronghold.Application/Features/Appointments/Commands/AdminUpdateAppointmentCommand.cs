using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.Exceptions;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Appointments.Commands;

public class AdminUpdateAppointmentCommand : IRequest<Unit>
{
    public int Id { get; set; }
    public int? TrainerId { get; set; }
    public int? NutritionistId { get; set; }
    public DateTime AppointmentDate { get; set; }
}

public class AdminUpdateAppointmentCommandHandler : IRequestHandler<AdminUpdateAppointmentCommand, Unit>
{
    private readonly IAppointmentRepository _appointmentRepository;
    private readonly ICurrentUserService _currentUserService;

    public AdminUpdateAppointmentCommandHandler(
        IAppointmentRepository appointmentRepository,
        ICurrentUserService currentUserService)
    {
        _appointmentRepository = appointmentRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(AdminUpdateAppointmentCommand request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

        var appointment = await _appointmentRepository.GetByIdAsync(request.Id, cancellationToken);
        if (appointment is null)
        {
            throw new KeyNotFoundException("Termin ne postoji.");
        }

        ValidateSingleStaffSelection(request.TrainerId, request.NutritionistId);
        var normalizedDate = NormalizeAndValidateAppointmentDate(request.AppointmentDate);

        if (request.TrainerId.HasValue)
        {
            var trainerExists = await _appointmentRepository.TrainerExistsAsync(request.TrainerId.Value, cancellationToken);
            if (!trainerExists)
            {
                throw new KeyNotFoundException("Trener ne postoji.");
            }
        }

        if (request.NutritionistId.HasValue)
        {
            var nutritionistExists = await _appointmentRepository.NutritionistExistsAsync(request.NutritionistId.Value, cancellationToken);
            if (!nutritionistExists)
            {
                throw new KeyNotFoundException("Nutricionist ne postoji.");
            }
        }

        var userHasAppointment = await _appointmentRepository.UserHasAppointmentOnDateAsync(
            appointment.UserId,
            normalizedDate,
            request.Id,
            cancellationToken);
        if (userHasAppointment)
        {
            throw new ConflictException("Korisnik vec ima termin na ovaj datum.");
        }

        var slotStart = normalizedDate;
        var slotEnd = normalizedDate.AddHours(1);

        if (request.TrainerId.HasValue)
        {
            var trainerBusy = await _appointmentRepository.IsTrainerBusyInSlotAsync(
                request.TrainerId.Value,
                slotStart,
                slotEnd,
                request.Id,
                cancellationToken);
            if (trainerBusy)
            {
                throw new InvalidOperationException("Odabrani trener je zauzet u ovom terminu.");
            }
        }

        if (request.NutritionistId.HasValue)
        {
            var nutritionistBusy = await _appointmentRepository.IsNutritionistBusyInSlotAsync(
                request.NutritionistId.Value,
                slotStart,
                slotEnd,
                request.Id,
                cancellationToken);
            if (nutritionistBusy)
            {
                throw new InvalidOperationException("Odabrani nutricionista je zauzet/a u ovom terminu.");
            }
        }

        appointment.TrainerId = request.TrainerId;
        appointment.NutritionistId = request.NutritionistId;
        appointment.AppointmentDate = normalizedDate;

        var updated = await _appointmentRepository.TryUpdateAsync(appointment, cancellationToken);
        if (!updated)
        {
            throw new ConflictException("Termin nije moguce izmijeniti jer je korisnik vec zauzeo taj dan ili je odabrani termin zauzet.");
        }

        return Unit.Value;
    }

    private void EnsureAdminAccess()
    {
        if (!_currentUserService.IsAuthenticated || _currentUserService.UserId is null)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }

        if (!_currentUserService.IsInRole("Admin"))
        {
            throw new UnauthorizedAccessException("Nemate dozvolu za ovu akciju.");
        }
    }

    private static void ValidateSingleStaffSelection(int? trainerId, int? nutritionistId)
    {
        if (trainerId is null && nutritionistId is null)
        {
            throw new ArgumentException("Morate odabrati trenera ili nutricionistu.");
        }

        if (trainerId is not null && nutritionistId is not null)
        {
            throw new ArgumentException("Termin moze biti samo kod trenera ili nutricioniste, ne oba.");
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
            throw new ArgumentException("Termini su moguci samo izmedju 9:00 i 17:00.");
        }

        if (localDate.Minute != 0 || localDate.Second != 0 || localDate.Millisecond != 0)
        {
            throw new ArgumentException("Termin mora biti unesen na puni sat.");
        }

        return new DateTime(localDate.Year, localDate.Month, localDate.Day, localDate.Hour, 0, 0, localDate.Kind);
    }
}

public class AdminUpdateAppointmentCommandValidator : AbstractValidator<AdminUpdateAppointmentCommand>
{
    public AdminUpdateAppointmentCommandValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");

        RuleFor(x => x.AppointmentDate).NotEmpty().WithMessage("{PropertyName} je obavezno.");

        RuleFor(x => x)
            .Must(x => x.TrainerId.HasValue || x.NutritionistId.HasValue)
            .WithMessage("Morate odabrati trenera ili nutricionistu.");

        RuleFor(x => x)
            .Must(x => !(x.TrainerId.HasValue && x.NutritionistId.HasValue))
            .WithMessage("Termin moze biti samo kod trenera ili nutricioniste, ne oba.");
    }
}

