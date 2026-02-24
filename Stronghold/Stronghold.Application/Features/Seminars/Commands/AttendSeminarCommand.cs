using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.Seminars.Commands;

public class AttendSeminarCommand : IRequest<Unit>
{
    public int SeminarId { get; set; }
}

public class AttendSeminarCommandHandler : IRequestHandler<AttendSeminarCommand, Unit>
{
    private readonly ISeminarRepository _seminarRepository;
    private readonly ICurrentUserService _currentUserService;

    public AttendSeminarCommandHandler(ISeminarRepository seminarRepository, ICurrentUserService currentUserService)
    {
        _seminarRepository = seminarRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(AttendSeminarCommand request, CancellationToken cancellationToken)
    {
        var userId = EnsureGymMemberAccess();
        var now = StrongholdTimeUtils.UtcNow;

        var seminar = await _seminarRepository.GetByIdAsync(request.SeminarId, cancellationToken);
        if (seminar is null || seminar.EventDate <= now || seminar.IsCancelled)
        {
            throw new KeyNotFoundException("Seminar ne postoji, zavrsio je, ili je otkazan.");
        }

        var attendeeCount = await _seminarRepository.CountAttendeesAsync(request.SeminarId, cancellationToken);
        if (attendeeCount >= seminar.MaxCapacity)
        {
            throw new InvalidOperationException("Seminar je popunjen. Nema slobodnih mjesta.");
        }

        var isAlreadyAttending = await _seminarRepository.IsUserAttendingAsync(userId, request.SeminarId, cancellationToken);
        if (isAlreadyAttending)
        {
            throw new InvalidOperationException("Korisnik je vec prijavljen na ovaj seminar");
        }

        var attendance = new SeminarAttendee
        {
            UserId = userId,
            SeminarId = request.SeminarId,
            RegisteredAt = now
        };

        await _seminarRepository.AddAttendeeAsync(attendance, cancellationToken);

        return Unit.Value;
    }

    private int EnsureGymMemberAccess()
    {
        if (!_currentUserService.IsAuthenticated || !_currentUserService.UserId.HasValue)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }

        if (!_currentUserService.IsInRole("GymMember"))
        {
            throw new UnauthorizedAccessException("Nemate dozvolu za ovu akciju.");
        }

        return _currentUserService.UserId.Value;
    }
}

public class AttendSeminarCommandValidator : AbstractValidator<AttendSeminarCommand>
{
    public AttendSeminarCommandValidator()
    {
        RuleFor(x => x.SeminarId).GreaterThan(0);
    }
}
