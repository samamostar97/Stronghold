using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Seminars.Commands;

public class CancelSeminarAttendanceCommand : IRequest<Unit>
{
    public int SeminarId { get; set; }
}

public class CancelSeminarAttendanceCommandHandler : IRequestHandler<CancelSeminarAttendanceCommand, Unit>
{
    private readonly ISeminarRepository _seminarRepository;
    private readonly ICurrentUserService _currentUserService;

    public CancelSeminarAttendanceCommandHandler(ISeminarRepository seminarRepository, ICurrentUserService currentUserService)
    {
        _seminarRepository = seminarRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(CancelSeminarAttendanceCommand request, CancellationToken cancellationToken)
    {
        var userId = EnsureGymMemberAccess();
        var now = StrongholdTimeUtils.UtcNow;

        var seminar = await _seminarRepository.GetByIdAsync(request.SeminarId, cancellationToken);
        if (seminar is not null && seminar.EventDate < now)
        {
            throw new InvalidOperationException("Nemoguce otkazati seminar u proslosti");
        }

        var attendance = await _seminarRepository.GetAttendanceAsync(userId, request.SeminarId, cancellationToken);
        if (attendance is null)
        {
            throw new InvalidOperationException("Niste prijavljeni na ovaj seminar");
        }

        await _seminarRepository.DeleteAttendeeAsync(attendance, cancellationToken);
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

public class CancelSeminarAttendanceCommandValidator : AbstractValidator<CancelSeminarAttendanceCommand>
{
    public CancelSeminarAttendanceCommandValidator()
    {
        RuleFor(x => x.SeminarId).GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
}

