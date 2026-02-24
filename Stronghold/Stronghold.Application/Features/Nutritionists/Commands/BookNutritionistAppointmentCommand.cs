using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Exceptions;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.Nutritionists.Commands;

public class BookNutritionistAppointmentCommand : IRequest<AppointmentResponse>
{
    public int NutritionistId { get; set; }
    public DateTime Date { get; set; }
}

public class BookNutritionistAppointmentCommandHandler
    : IRequestHandler<BookNutritionistAppointmentCommand, AppointmentResponse>
{
    private readonly INutritionistRepository _nutritionistRepository;
    private readonly ICurrentUserService _currentUserService;

    public BookNutritionistAppointmentCommandHandler(
        INutritionistRepository nutritionistRepository,
        ICurrentUserService currentUserService)
    {
        _nutritionistRepository = nutritionistRepository;
        _currentUserService = currentUserService;
    }

    public async Task<AppointmentResponse> Handle(BookNutritionistAppointmentCommand request, CancellationToken cancellationToken)
    {
        EnsureGymMemberAccess();

        var normalizedDate = NormalizeAndValidateAppointmentDate(request.Date);

        var nutritionist = await _nutritionistRepository.GetByIdAsync(request.NutritionistId, cancellationToken);
        if (nutritionist is null)
        {
            throw new KeyNotFoundException("Nutricionist ne postoji.");
        }

        var userId = _currentUserService.UserId!.Value;

        var userHasAppointment = await _nutritionistRepository.UserHasAppointmentOnDateAsync(
            userId,
            normalizedDate,
            cancellationToken);
        if (userHasAppointment)
        {
            throw new ConflictException("Korisnik vec ima termin na ovaj datum.");
        }

        var slotStart = normalizedDate;
        var slotEnd = normalizedDate.AddHours(1);
        var isNutritionistBusy = await _nutritionistRepository.IsBusyInSlotAsync(
            request.NutritionistId,
            slotStart,
            slotEnd,
            cancellationToken);
        if (isNutritionistBusy)
        {
            throw new InvalidOperationException("Odabrani nutricionist je zauzet u ovom terminu, pokusajte drugi termin.");
        }

        var appointment = new Appointment
        {
            UserId = userId,
            NutritionistId = request.NutritionistId,
            AppointmentDate = normalizedDate
        };

        await _nutritionistRepository.AddAppointmentAsync(appointment, cancellationToken);

        return new AppointmentResponse
        {
            Id = appointment.Id,
            NutritionistName = nutritionist.FirstName + " " + nutritionist.LastName,
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

public class BookNutritionistAppointmentCommandValidator : AbstractValidator<BookNutritionistAppointmentCommand>
{
    public BookNutritionistAppointmentCommandValidator()
    {
        RuleFor(x => x.NutritionistId)
            .GreaterThan(0);

        RuleFor(x => x.Date)
            .NotEmpty();
    }
}
