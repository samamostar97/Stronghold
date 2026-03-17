using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Seminars.RegisterForSeminar;

public class RegisterForSeminarCommandHandler : IRequestHandler<RegisterForSeminarCommand, Unit>
{
    private readonly ISeminarRepository _seminarRepository;
    private readonly ISeminarRegistrationRepository _registrationRepository;
    private readonly ICurrentUserService _currentUserService;

    public RegisterForSeminarCommandHandler(
        ISeminarRepository seminarRepository,
        ISeminarRegistrationRepository registrationRepository,
        ICurrentUserService currentUserService)
    {
        _seminarRepository = seminarRepository;
        _registrationRepository = registrationRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(RegisterForSeminarCommand request, CancellationToken cancellationToken)
    {
        var seminar = await _seminarRepository.GetByIdAsync(request.SeminarId)
            ?? throw new NotFoundException("Seminar", request.SeminarId);

        if (seminar.StartDate < DateTime.UtcNow)
            throw new InvalidOperationException("Seminar je zavrsen, prijava nije moguca.");

        var userId = _currentUserService.UserId;

        if (await _registrationRepository.IsUserRegisteredAsync(request.SeminarId, userId))
            throw new ConflictException("Vec ste prijavljeni na ovaj seminar.");

        var count = await _registrationRepository.GetRegistrationCountAsync(request.SeminarId);
        if (count >= seminar.MaxCapacity)
            throw new InvalidOperationException("Kapacitet seminara je popunjen.");

        var registration = new SeminarRegistration
        {
            SeminarId = request.SeminarId,
            UserId = userId
        };

        await _registrationRepository.AddAsync(registration);
        await _registrationRepository.SaveChangesAsync();

        return Unit.Value;
    }
}
