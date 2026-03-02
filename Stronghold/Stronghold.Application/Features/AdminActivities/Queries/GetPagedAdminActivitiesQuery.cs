using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.Features.AdminActivities.DTOs;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.AdminActivities.Queries;

public class GetPagedAdminActivitiesQuery : IRequest<PagedResult<AdminActivityResponse>>, IAuthorizeAdminRequest
{
    public AdminActivityFilter Filter { get; set; } = new();
}

public class GetPagedAdminActivitiesQueryHandler : IRequestHandler<GetPagedAdminActivitiesQuery, PagedResult<AdminActivityResponse>>
{
    private readonly IAdminActivityService _adminActivityService;

    public GetPagedAdminActivitiesQueryHandler(IAdminActivityService adminActivityService)
    {
        _adminActivityService = adminActivityService;
    }

    public async Task<PagedResult<AdminActivityResponse>> Handle(
        GetPagedAdminActivitiesQuery request,
        CancellationToken cancellationToken)
    {
        var filter = request.Filter ?? new AdminActivityFilter();
        return await _adminActivityService.GetPagedAsync(filter, cancellationToken);
    }
}

public class GetPagedAdminActivitiesQueryValidator : AbstractValidator<GetPagedAdminActivitiesQuery>
{
    public GetPagedAdminActivitiesQueryValidator()
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

        RuleFor(x => x.Filter.ActionType)
            .Must(x => x is "add" or "delete")
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.ActionType))
            .WithMessage("ActionType mora biti 'add' ili 'delete'.");

        RuleFor(x => x.Filter.EntityType)
            .MaximumLength(100).WithMessage("{PropertyName} ne smije imati vise od 100 karaktera.")
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.EntityType));
    }

    private static bool BeValidOrderBy(string? orderBy)
    {
        var value = orderBy?.Trim().ToLowerInvariant();
        return value is
            "createdat" or
            "createdatdesc" or
            "admin" or
            "admindesc" or
            "actiontype" or
            "actiontypedesc" or
            "entitytype" or
            "entitytypedesc";
    }
}
