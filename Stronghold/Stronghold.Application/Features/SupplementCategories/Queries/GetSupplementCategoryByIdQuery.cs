using FluentValidation;
using MediatR;
using Stronghold.Application.Features.SupplementCategories.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.SupplementCategories.Queries;

public class GetSupplementCategoryByIdQuery : IRequest<SupplementCategoryResponse>
{
    public int Id { get; set; }
}

public class GetSupplementCategoryByIdQueryHandler
    : IRequestHandler<GetSupplementCategoryByIdQuery, SupplementCategoryResponse>
{
    private readonly ISupplementCategoryRepository _repository;
    private readonly ICurrentUserService _currentUserService;

    public GetSupplementCategoryByIdQueryHandler(
        ISupplementCategoryRepository repository,
        ICurrentUserService currentUserService)
    {
        _repository = repository;
        _currentUserService = currentUserService;
    }

    public async Task<SupplementCategoryResponse> Handle(
        GetSupplementCategoryByIdQuery request,
        CancellationToken cancellationToken)
    {
        EnsureReadAccess();

        var entity = await _repository.GetByIdAsync(request.Id, cancellationToken);
        if (entity is null)
        {
            throw new KeyNotFoundException($"Kategorija suplementa sa id '{request.Id}' ne postoji.");
        }

        return MapToResponse(entity);
    }

    private void EnsureReadAccess()
    {
        if (!_currentUserService.IsAuthenticated || _currentUserService.UserId is null)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }

        if (!_currentUserService.IsInRole("Admin") && !_currentUserService.IsInRole("GymMember"))
        {
            throw new UnauthorizedAccessException("Nemate dozvolu za ovu akciju.");
        }
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
        RuleFor(x => x.Id).GreaterThan(0);
    }
}
