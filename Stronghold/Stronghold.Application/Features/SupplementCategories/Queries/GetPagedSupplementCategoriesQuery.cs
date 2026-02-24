using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.Features.SupplementCategories.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.SupplementCategories.Queries;

public class GetPagedSupplementCategoriesQuery : IRequest<PagedResult<SupplementCategoryResponse>>
{
    public SupplementCategoryFilter Filter { get; set; } = new();
}

public class GetPagedSupplementCategoriesQueryHandler
    : IRequestHandler<GetPagedSupplementCategoriesQuery, PagedResult<SupplementCategoryResponse>>
{
    private readonly ISupplementCategoryRepository _repository;
    private readonly ICurrentUserService _currentUserService;

    public GetPagedSupplementCategoriesQueryHandler(
        ISupplementCategoryRepository repository,
        ICurrentUserService currentUserService)
    {
        _repository = repository;
        _currentUserService = currentUserService;
    }

    public async Task<PagedResult<SupplementCategoryResponse>> Handle(
        GetPagedSupplementCategoriesQuery request,
        CancellationToken cancellationToken)
    {
        EnsureReadAccess();

        var filter = request.Filter ?? new SupplementCategoryFilter();
        var page = await _repository.GetPagedAsync(filter, cancellationToken);

        return new PagedResult<SupplementCategoryResponse>
        {
            Items = page.Items.Select(MapToResponse).ToList(),
            TotalCount = page.TotalCount,
            PageNumber = page.PageNumber
        };
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

public class GetPagedSupplementCategoriesQueryValidator : AbstractValidator<GetPagedSupplementCategoriesQuery>
{
    public GetPagedSupplementCategoriesQueryValidator()
    {
        RuleFor(x => x.Filter).NotNull();

        RuleFor(x => x.Filter.PageNumber)
            .GreaterThanOrEqualTo(1);

        RuleFor(x => x.Filter.PageSize)
            .GreaterThanOrEqualTo(1)
            .LessThanOrEqualTo(100);

        RuleFor(x => x.Filter.Search)
            .MaximumLength(200)
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.Search));

        RuleFor(x => x.Filter.OrderBy)
            .MaximumLength(30)
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
