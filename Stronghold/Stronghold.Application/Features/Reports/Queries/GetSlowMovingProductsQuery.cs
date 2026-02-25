using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Reports.DTOs;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Reports.Queries;

public class GetSlowMovingProductsQuery : IRequest<PagedResult<SlowMovingProductResponse>>, IAuthorizeAdminRequest
{
    public SlowMovingProductQueryFilter Filter { get; set; } = new();
}

public class GetSlowMovingProductsQueryHandler : IRequestHandler<GetSlowMovingProductsQuery, PagedResult<SlowMovingProductResponse>>
{
    private readonly IReportService _reportService;

    public GetSlowMovingProductsQueryHandler(
        IReportService reportService)
    {
        _reportService = reportService;
    }

public async Task<PagedResult<SlowMovingProductResponse>> Handle(GetSlowMovingProductsQuery request, CancellationToken cancellationToken)
    {
        return await _reportService.GetSlowMovingProductsPagedAsync(request.Filter);
    }
    }

public class GetSlowMovingProductsQueryValidator : AbstractValidator<GetSlowMovingProductsQuery>
{
    public GetSlowMovingProductsQueryValidator()
    {
        RuleFor(x => x.Filter).NotNull().WithMessage("{PropertyName} je obavezno.");

        RuleFor(x => x.Filter.DaysToAnalyze)
            .InclusiveBetween(1, 365).WithMessage("{PropertyName} mora biti u dozvoljenom opsegu.");

        RuleFor(x => x.Filter.PageNumber)
            .GreaterThanOrEqualTo(1).WithMessage("{PropertyName} mora biti vece ili jednako dozvoljenoj vrijednosti.");

        RuleFor(x => x.Filter.PageSize)
            .InclusiveBetween(1, 100).WithMessage("{PropertyName} mora biti u dozvoljenom opsegu.");

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