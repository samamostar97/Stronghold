using FluentValidation;
using MediatR;
using Stronghold.Application.Exceptions;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Nutritionists.Commands;

public class DeleteNutritionistCommand : IRequest<Unit>
{
    public int Id { get; set; }
}

public class DeleteNutritionistCommandHandler : IRequestHandler<DeleteNutritionistCommand, Unit>
{
    private readonly INutritionistRepository _nutritionistRepository;
    private readonly ICurrentUserService _currentUserService;

    public DeleteNutritionistCommandHandler(
        INutritionistRepository nutritionistRepository,
        ICurrentUserService currentUserService)
    {
        _nutritionistRepository = nutritionistRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(DeleteNutritionistCommand request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

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

public class DeleteNutritionistCommandValidator : AbstractValidator<DeleteNutritionistCommand>
{
    public DeleteNutritionistCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
}

