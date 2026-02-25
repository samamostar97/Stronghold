using FluentValidation;
using MediatR;
using Stronghold.Application.Features.SupplementCategories.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.SupplementCategories.Queries;

public class GetSupplementCategoryByIdQuery : IRequest<SupplementCategoryResponse>, IAuthorizeAdminOrGymMemberRequest
{
    public int Id { get; set; }
}

public class GetSupplementCategoryByIdQueryHandler
    : IRequestHandler<GetSupplementCategoryByIdQuery, SupplementCategoryResponse>
{
    private readonly ISupplementCategoryRepository _repository;

    public GetSupplementCategoryByIdQueryHandler(
        ISupplementCategoryRepository repository)
    {
        _repository = repository;
    }

public async Task<SupplementCategoryResponse> Handle(
        GetSupplementCategoryByIdQuery request,
        CancellationToken cancellationToken)
    {
        var entity = await _repository.GetByIdAsync(request.Id, cancellationToken);
        if (entity is null)
        {
            throw new KeyNotFoundException($"Kategorija suplementa sa id '{request.Id}' ne postoji.");
        }

        return MapToResponse(entity);
    }

private static SupplementCategoryResponse MapToResponse(SupplementCategory entity)
    {
        return new SupplementCategoryResponse
        {
            Id = entity.Id,
            Name = entity.Name,
            CreatedAt = entity.CreatedAt
        };
    }
    }

public class GetSupplementCategoryByIdQueryValidator : AbstractValidator<GetSupplementCategoryByIdQuery>
{
    public GetSupplementCategoryByIdQueryValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
    }