using FluentValidation;
using MediatR;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Features.SupplementCategories.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.SupplementCategories.Commands;

public class CreateSupplementCategoryCommand : IRequest<SupplementCategoryResponse>
{
    public string Name { get; set; } = string.Empty;
}

public class CreateSupplementCategoryCommandHandler : IRequestHandler<CreateSupplementCategoryCommand, SupplementCategoryResponse>
{
    private readonly ISupplementCategoryRepository _repository;
    private readonly ICurrentUserService _currentUserService;

    public CreateSupplementCategoryCommandHandler(
        ISupplementCategoryRepository repository,
        ICurrentUserService currentUserService)
    {
        _repository = repository;
        _currentUserService = currentUserService;
    }

    public async Task<SupplementCategoryResponse> Handle(CreateSupplementCategoryCommand request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

        var exists = await _repository.ExistsByNameAsync(request.Name, cancellationToken: cancellationToken);
        if (exists)
        {
            throw new ConflictException("Kategorija sa ovim nazivom vec postoji.");
        }

        var entity = new SupplementCategory
        {
            Name = request.Name.Trim()
        };

        await _repository.AddAsync(entity, cancellationToken);

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

public class CreateSupplementCategoryCommandValidator : AbstractValidator<CreateSupplementCategoryCommand>
{
    public CreateSupplementCategoryCommandValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MinimumLength(2).WithMessage("{PropertyName} mora imati najmanje 2 karaktera.")
            .MaximumLength(100).WithMessage("{PropertyName} ne smije imati vise od 100 karaktera.");
    }
}

