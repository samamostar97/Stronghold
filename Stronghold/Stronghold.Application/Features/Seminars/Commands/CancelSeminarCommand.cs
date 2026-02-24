using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Seminars.Commands;

public class CancelSeminarCommand : IRequest<Unit>
{
    public int Id { get; set; }
}

public class CancelSeminarCommandHandler : IRequestHandler<CancelSeminarCommand, Unit>
{
    private readonly ISeminarRepository _seminarRepository;
    private readonly ICurrentUserService _currentUserService;

    public CancelSeminarCommandHandler(ISeminarRepository seminarRepository, ICurrentUserService currentUserService)
    {
        _seminarRepository = seminarRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(CancelSeminarCommand request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

        var seminar = await _seminarRepository.GetByIdAsync(request.Id, cancellationToken);
        if (seminar is null)
        {
            throw new KeyNotFoundException($"Seminar sa id '{request.Id}' ne postoji.");
        }

        if (seminar.IsCancelled)
        {
            throw new InvalidOperationException("Seminar je vec otkazan.");
        }

        if (seminar.EventDate <= StrongholdTimeUtils.UtcNow)
        {
            throw new InvalidOperationException("Nije moguce otkazati seminar koji je vec poceo ili je zavrsen.");
        }

        seminar.IsCancelled = true;
        await _seminarRepository.UpdateAsync(seminar, cancellationToken);

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

public class CancelSeminarCommandValidator : AbstractValidator<CancelSeminarCommand>
{
    public CancelSeminarCommandValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0);
    }
}
