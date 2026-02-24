using FluentValidation;
using MediatR;
using Stronghold.Application.Exceptions;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.SupplementCategories.Commands;

public class DeleteSupplementCategoryCommand : IRequest<Unit>
{
    public int Id { get; set; }
}

public class DeleteSupplementCategoryCommandHandler : IRequestHandler<DeleteSupplementCategoryCommand, Unit>
{
    private readonly ISupplementCategoryRepository _repository;
    private readonly ICurrentUserService _currentUserService;

    public DeleteSupplementCategoryCommandHandler(
        ISupplementCategoryRepository repository,
        ICurrentUserService currentUserService)
    {
        _repository = repository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(DeleteSupplementCategoryCommand request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

        var entity = await _repository.GetByIdAsync(request.Id, cancellationToken);
        if (entity is null)
        {
            throw new KeyNotFoundException($"Kategorija suplementa sa id '{request.Id}' ne postoji.");
        }

        var hasSupplements = await _repository.HasSupplementsAsync(entity.Id, cancellationToken);
        if (hasSupplements)
        {
            throw new EntityHasDependentsException("kategoriju", "suplemente");
        }

        await _repository.DeleteAsync(entity, cancellationToken);
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

public class DeleteSupplementCategoryCommandValidator : AbstractValidator<DeleteSupplementCategoryCommand>
{
    public DeleteSupplementCategoryCommandValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0);
    }
}
