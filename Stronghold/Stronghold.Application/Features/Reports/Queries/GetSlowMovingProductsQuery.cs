using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Reports.DTOs;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Reports.Queries;

public class GetSlowMovingProductsQuery : IRequest<PagedResult<SlowMovingProductResponse>>
{
    public SlowMovingProductQueryFilter Filter { get; set; } = new();
}

public class GetSlowMovingProductsQueryHandler : IRequestHandler<GetSlowMovingProductsQuery, PagedResult<SlowMovingProductResponse>>
{
    private readonly IReportService _reportService;
    private readonly ICurrentUserService _currentUserService;

    public GetSlowMovingProductsQueryHandler(
        IReportService reportService,
        ICurrentUserService currentUserService)
    {
        _reportService = reportService;
        _currentUserService = currentUserService;
    }

    public async Task<PagedResult<SlowMovingProductResponse>> Handle(GetSlowMovingProductsQuery request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();
        return await _reportService.GetSlowMovingProductsPagedAsync(request.Filter);
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

public class GetSlowMovingProductsQueryValidator : AbstractValidator<GetSlowMovingProductsQuery>
{
    public GetSlowMovingProductsQueryValidator()
    {
        RuleFor(x => x.Filter).NotNull();

        RuleFor(x => x.Filter.DaysToAnalyze)
            .InclusiveBetween(1, 365);

        RuleFor(x => x.Filter.PageNumber)
            .GreaterThanOrEqualTo(1);

        RuleFor(x => x.Filter.PageSize)
            .InclusiveBetween(1, 100);

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
        var normalized = orderBy?.Trim().ToLower();
        return normalized is
            "name" or
            "namedesc" or
            "category" or
            "categorydesc" or
            "price" or
            "pricedesc" or
            "quantitysold" or
            "quantitysolddesc" or
            "dayssincelastsale" or
            "dayssincelastsaledesc";
    }
}
