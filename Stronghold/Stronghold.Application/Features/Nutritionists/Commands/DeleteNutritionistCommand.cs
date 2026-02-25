using FluentValidation;
using MediatR;
using Stronghold.Application.Exceptions;
using Stronghold.Application.IRepositories;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Nutritionists.Commands;

public class DeleteNutritionistCommand : IRequest<Unit>, IAuthorizeAdminRequest
{
    public int Id { get; set; }
}

public class DeleteNutritionistCommandHandler : IRequestHandler<DeleteNutritionistCommand, Unit>
{
    private readonly INutritionistRepository _nutritionistRepository;

    public DeleteNutritionistCommandHandler(
        INutritionistRepository nutritionistRepository)
    {
        _nutritionistRepository = nutritionistRepository;
    }

public async Task<Unit> Handle(DeleteNutritionistCommand request, CancellationToken cancellationToken)
    {
        var nutritionist = await _nutritionistRepository.GetByIdAsync(request.Id, cancellationToken);
        if (nutritionist is null)
        {
            throw new KeyNotFoundException($"Nutricionista sa id '{request.Id}' ne postoji.");
        }

        var hasAppointments = await _nutritionistRepository.HasAppointmentsAsync(nutritionist.Id, cancellationToken);
        if (hasAppointments)
        {
            throw new EntityHasDependentsException("nutricionistu", "termine");
        }

        await _nutritionistRepository.DeleteAsync(nutritionist, cancellationToken);
        return Unit.Value;
    }
    }

public class DeleteNutritionistCommandValidator : AbstractValidator<DeleteNutritionistCommand>
{
    public DeleteNutritionistCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
    }