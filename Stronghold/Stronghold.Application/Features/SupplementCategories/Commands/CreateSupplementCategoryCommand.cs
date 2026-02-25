using FluentValidation;
using MediatR;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Features.SupplementCategories.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.SupplementCategories.Commands;

public class CreateSupplementCategoryCommand : IRequest<SupplementCategoryResponse>, IAuthorizeAdminRequest
{
    public string Name { get; set; } = string.Empty;
}

public class CreateSupplementCategoryCommandHandler : IRequestHandler<CreateSupplementCategoryCommand, SupplementCategoryResponse>
{
    private readonly ISupplementCategoryRepository _repository;

    public CreateSupplementCategoryCommandHandler(
        ISupplementCategoryRepository repository)
    {
        _repository = repository;
    }

public async Task<SupplementCategoryResponse> Handle(CreateSupplementCategoryCommand request, CancellationToken cancellationToken)
    {
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