using FluentValidation;
using MediatR;
using Stronghold.Application.Exceptions;
using Stronghold.Application.IRepositories;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Trainers.Commands;

public class DeleteTrainerCommand : IRequest<Unit>, IAuthorizeAdminRequest
{
    public int Id { get; set; }
}

public class DeleteTrainerCommandHandler : IRequestHandler<DeleteTrainerCommand, Unit>
{
    private readonly ITrainerRepository _trainerRepository;

    public DeleteTrainerCommandHandler(ITrainerRepository trainerRepository)
    {
        _trainerRepository = trainerRepository;
    }

public async Task<Unit> Handle(DeleteTrainerCommand request, CancellationToken cancellationToken)
    {
        var trainer = await _trainerRepository.GetByIdAsync(request.Id, cancellationToken);
        if (trainer is null)
        {
            throw new KeyNotFoundException($"Trener sa id '{request.Id}' ne postoji.");
        }

        var hasAppointments = await _trainerRepository.HasAppointmentsAsync(trainer.Id, cancellationToken);
        if (hasAppointments)
        {
            throw new EntityHasDependentsException("trenera", "termine");
        }

        await _trainerRepository.DeleteAsync(trainer, cancellationToken);
        return Unit.Value;
    }
    }

public class DeleteTrainerCommandValidator : AbstractValidator<DeleteTrainerCommand>
{
    public DeleteTrainerCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
    }