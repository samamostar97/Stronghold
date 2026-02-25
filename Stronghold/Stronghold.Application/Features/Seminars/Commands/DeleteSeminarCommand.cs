using FluentValidation;
using MediatR;
using Stronghold.Application.IRepositories;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Seminars.Commands;

public class DeleteSeminarCommand : IRequest<Unit>, IAuthorizeAdminRequest
{
    public int Id { get; set; }
}

public class DeleteSeminarCommandHandler : IRequestHandler<DeleteSeminarCommand, Unit>
{
    private readonly ISeminarRepository _seminarRepository;

    public DeleteSeminarCommandHandler(ISeminarRepository seminarRepository)
    {
        _seminarRepository = seminarRepository;
    }

public async Task<Unit> Handle(DeleteSeminarCommand request, CancellationToken cancellationToken)
    {
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
    }

public class DeleteSeminarCommandValidator : AbstractValidator<DeleteSeminarCommand>
{
    public DeleteSeminarCommandValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
    }