using FluentValidation;
using MediatR;
using Stronghold.Application.Features.SupplementCategories.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.SupplementCategories.Queries;

public class GetSupplementCategoriesQuery : IRequest<IReadOnlyList<SupplementCategoryResponse>>
{
    public SupplementCategoryFilter Filter { get; set; } = new();
}

public class GetSupplementCategoriesQueryHandler
    : IRequestHandler<GetSupplementCategoriesQuery, IReadOnlyList<SupplementCategoryResponse>>
{
    private readonly ISupplementCategoryRepository _repository;
    private readonly ICurrentUserService _currentUserService;

    public GetSupplementCategoriesQueryHandler(
        ISupplementCategoryRepository repository,
        ICurrentUserService currentUserService)
    {
        _repository = repository;
        _currentUserService = currentUserService;
    }

    public async Task<IReadOnlyList<SupplementCategoryResponse>> Handle(
        GetSupplementCategoriesQuery request,
        CancellationToken cancellationToken)
    {
        EnsureReadAccess();

        var filter = request.Filter ?? new SupplementCategoryFilter();
        filter.PageNumber = 1;
        filter.PageSize = int.MaxValue;
        var page = await _repository.GetPagedAsync(filter, cancellationToken);
        return page.Items.Select(MapToResponse).ToList();
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

public class GetSupplementCategoriesQueryValidator : AbstractValidator<GetSupplementCategoriesQuery>
{
    public GetSupplementCategoriesQueryValidator()
    {
        RuleFor(x => x.Filter).NotNull().WithMessage("{PropertyName} je obavezno.");

        RuleFor(x => x.Filter.Search)
            .MaximumLength(200).WithMessage("{PropertyName} ne smije imati vise od 200 karaktera.")
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.Search));

        RuleFor(x => x.Filter.OrderBy)
            .MaximumLength(30).WithMessage("{PropertyName} ne smije imati vise od 30 karaktera.")
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.OrderBy));

        RuleFor(x => x.Filter.OrderBy)
            .Must(BeValidOrderBy)
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.OrderBy))
            .WithMessage("Neispravna vrijednost za sortiranje.");
    }

    private static bool BeValidOrderBy(string? orderBy)
    {
        var value = orderBy?.Trim().ToLowerInvariant();
        return value is "name" or "namedesc" or "createdat" or "createdatdesc";
    }
}

