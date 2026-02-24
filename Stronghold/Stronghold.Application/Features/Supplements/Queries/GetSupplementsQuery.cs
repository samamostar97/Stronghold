using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Supplements.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.Supplements.Queries;

public class GetSupplementsQuery : IRequest<IReadOnlyList<SupplementResponse>>
{
    public SupplementFilter Filter { get; set; } = new();
}

public class GetSupplementsQueryHandler : IRequestHandler<GetSupplementsQuery, IReadOnlyList<SupplementResponse>>
{
    private readonly ISupplementRepository _supplementRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetSupplementsQueryHandler(ISupplementRepository supplementRepository, ICurrentUserService currentUserService)
    {
        _supplementRepository = supplementRepository;
        _currentUserService = currentUserService;
    }

    public async Task<IReadOnlyList<SupplementResponse>> Handle(GetSupplementsQuery request, CancellationToken cancellationToken)
    {
        EnsureReadAccess();

        var filter = request.Filter ?? new SupplementFilter();
        filter.PageNumber = 1;
        filter.PageSize = int.MaxValue;

        var page = await _supplementRepository.GetPagedAsync(filter, cancellationToken);
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

    private static SupplementResponse MapToResponse(Supplement supplement)
    {
        return new SupplementResponse
        {
            Id = supplement.Id,
            Name = supplement.Name,
            Price = supplement.Price,
            Description = supplement.Description,
            SupplementCategoryId = supplement.SupplementCategoryId,
            SupplementCategoryName = supplement.SupplementCategory?.Name ?? string.Empty,
            SupplierId = supplement.SupplierId,
            SupplierName = supplement.Supplier?.Name ?? string.Empty,
            ImageUrl = supplement.SupplementImageUrl,
            CreatedAt = supplement.CreatedAt
        };
    }
}

public class GetSupplementsQueryValidator : AbstractValidator<GetSupplementsQuery>
{
    public GetSupplementsQueryValidator()
    {
        RuleFor(x => x.Filter).NotNull();

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

        RuleFor(x => x.Filter.SupplementCategoryId)
            .GreaterThan(0)
            .When(x => x.Filter.SupplementCategoryId.HasValue);
    }

    private static bool BeValidOrderBy(string? orderBy)
    {
        var value = orderBy?.Trim().ToLowerInvariant();
        return value is
            "name" or
            "namedesc" or
            "price" or
            "pricedesc" or
            "category" or
            "categorydesc" or
            "supplier" or
            "supplierdesc" or
            "createdat" or
            "createdatdesc";
    }
}
