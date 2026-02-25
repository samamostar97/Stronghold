using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.IRepositories;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Seminars.Commands;

public class CancelSeminarCommand : IRequest<Unit>, IAuthorizeAdminRequest
{
    public int Id { get; set; }
}

public class CancelSeminarCommandHandler : IRequestHandler<CancelSeminarCommand, Unit>
{
    private readonly ISeminarRepository _seminarRepository;

    public CancelSeminarCommandHandler(ISeminarRepository seminarRepository)
    {
        _seminarRepository = seminarRepository;
    }

public async Task<Unit> Handle(CancelSeminarCommand request, CancellationToken cancellationToken)
    {
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
    }

public class CancelSeminarCommandValidator : AbstractValidator<CancelSeminarCommand>
{
    public CancelSeminarCommandValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
    }