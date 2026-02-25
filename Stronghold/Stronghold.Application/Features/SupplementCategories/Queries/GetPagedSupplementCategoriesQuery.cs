using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.Features.SupplementCategories.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.SupplementCategories.Queries;

public class GetPagedSupplementCategoriesQuery : IRequest<PagedResult<SupplementCategoryResponse>>, IAuthorizeAdminOrGymMemberRequest
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
        var filter = request.Filter ?? new SupplementCategoryFilter();
        var page = await _repository.GetPagedAsync(filter, cancellationToken);

        return new PagedResult<SupplementCategoryResponse>
        {
            Items = page.Items.Select(MapToResponse).ToList(),
            TotalCount = page.TotalCount,
            PageNumber = page.PageNumber
        };
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
        RuleFor(x => x.Filter).NotNull().WithMessage("{PropertyName} je obavezno.");

        RuleFor(x => x.Filter.PageNumber)
            .GreaterThanOrEqualTo(1).WithMessage("{PropertyName} mora biti vece ili jednako dozvoljenoj vrijednosti.");

        RuleFor(x => x.Filter.PageSize)
            .GreaterThanOrEqualTo(1).WithMessage("{PropertyName} mora biti vece ili jednako dozvoljenoj vrijednosti.")
            .LessThanOrEqualTo(100).WithMessage("{PropertyName} mora biti manje ili jednako dozvoljenoj vrijednosti.");

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