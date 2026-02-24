using FluentValidation;
using MediatR;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Seminars.Commands;

public class DeleteSeminarCommand : IRequest<Unit>
{
    public int Id { get; set; }
}

public class DeleteSeminarCommandHandler : IRequestHandler<DeleteSeminarCommand, Unit>
{
    private readonly ISeminarRepository _seminarRepository;
    private readonly ICurrentUserService _currentUserService;

    public DeleteSeminarCommandHandler(ISeminarRepository seminarRepository, ICurrentUserService currentUserService)
    {
        _seminarRepository = seminarRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(DeleteSeminarCommand request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

        var seminar = await _seminarRepository.GetByIdAsync(request.Id, cancellationToken);
        if (seminar is null)
        {
            throw new KeyNotFoundException($"Seminar sa id '{request.Id}' ne postoji.");
        }

        var attendees = await _seminarRepository.GetAttendeesBySeminarIdAsync(request.Id, cancellationToken: cancellationToken);
        foreach (var attendee in attendees)
        {
            await _seminarRepository.DeleteAttendeeAsync(attendee, cancellationToken);
        }

        await _seminarRepository.DeleteAsync(seminar, cancellationToken);
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
}

public class DeleteSeminarCommandValidator : AbstractValidator<DeleteSeminarCommand>
{
    public DeleteSeminarCommandValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
}

