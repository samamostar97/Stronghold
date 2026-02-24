using FluentValidation;
using MediatR;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Features.SupplementCategories.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.SupplementCategories.Commands;

public class UpdateSupplementCategoryCommand : IRequest<SupplementCategoryResponse>
{
    public int Id { get; set; }
    public string? Name { get; set; }
}

public class UpdateSupplementCategoryCommandHandler : IRequestHandler<UpdateSupplementCategoryCommand, SupplementCategoryResponse>
{
    private readonly ISupplementCategoryRepository _repository;
    private readonly ICurrentUserService _currentUserService;

    public UpdateSupplementCategoryCommandHandler(
        ISupplementCategoryRepository repository,
        ICurrentUserService currentUserService)
    {
        _repository = repository;
        _currentUserService = currentUserService;
    }

    public async Task<SupplementCategoryResponse> Handle(UpdateSupplementCategoryCommand request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

        var entity = await _repository.GetByIdAsync(request.Id, cancellationToken);
        if (entity is null)
        {
            throw new KeyNotFoundException($"Kategorija suplementa sa id '{request.Id}' ne postoji.");
        }

        if (!string.IsNullOrWhiteSpace(request.Name))
        {
            var exists = await _repository.ExistsByNameAsync(request.Name, entity.Id, cancellationToken);
            if (exists)
            {
                throw new ConflictException("Kategorija sa ovim nazivom vec postoji.");
            }

            entity.Name = request.Name.Trim();
        }

        await _repository.UpdateAsync(entity, cancellationToken);

        return new SupplementCategoryResponse
        {
            Id = entity.Id,
            Name = entity.Name,
            CreatedAt = entity.CreatedAt
        };
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

public class UpdateSupplementCategoryCommandValidator : AbstractValidator<UpdateSupplementCategoryCommand>
{
    public UpdateSupplementCategoryCommandValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0);

        RuleFor(x => x.Name)
            .NotEmpty()
            .MinimumLength(2)
            .MaximumLength(100)
            .When(x => x.Name is not null);
    }
}
