using FluentValidation;
using MediatR;
using Stronghold.Application.Exceptions;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.SupplementCategories.Commands;

public class DeleteSupplementCategoryCommand : IRequest<Unit>, IAuthorizeAdminRequest
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
    }

public class DeleteSupplementCategoryCommandValidator : AbstractValidator<DeleteSupplementCategoryCommand>
{
    public DeleteSupplementCategoryCommandValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
    }