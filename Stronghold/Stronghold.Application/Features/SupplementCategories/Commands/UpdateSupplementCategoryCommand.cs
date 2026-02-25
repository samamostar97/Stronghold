using FluentValidation;
using MediatR;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Features.SupplementCategories.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.SupplementCategories.Commands;

public class UpdateSupplementCategoryCommand : IRequest<SupplementCategoryResponse>, IAuthorizeAdminRequest
{
    public int Id { get; set; }

public string? Name { get; set; }
}

public class UpdateSupplementCategoryCommandHandler : IRequestHandler<UpdateSupplementCategoryCommand, SupplementCategoryResponse>
{
    private readonly ISupplementCategoryRepository _repository;

    public UpdateSupplementCategoryCommandHandler(
        ISupplementCategoryRepository repository)
    {
        _repository = repository;
    }

public async Task<SupplementCategoryResponse> Handle(UpdateSupplementCategoryCommand request, CancellationToken cancellationToken)
    {
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
    }

public class UpdateSupplementCategoryCommandValidator : AbstractValidator<UpdateSupplementCategoryCommand>
{
    public UpdateSupplementCategoryCommandValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");

        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("{PropertyName} je obavezno.")
            .MinimumLength(2).WithMessage("{PropertyName} mora imati najmanje 2 karaktera.")
            .MaximumLength(100).WithMessage("{PropertyName} ne smije imati vise od 100 karaktera.")
            .When(x => x.Name is not null);
    }
    }