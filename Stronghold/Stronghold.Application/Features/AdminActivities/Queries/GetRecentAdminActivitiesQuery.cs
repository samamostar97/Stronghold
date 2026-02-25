using FluentValidation;
using MediatR;
using Stronghold.Application.Features.AdminActivities.DTOs;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.AdminActivities.Queries;

public class GetRecentAdminActivitiesQuery : IRequest<IReadOnlyList<AdminActivityResponse>>, IAuthorizeAdminRequest
{
    public int Count { get; set; } = 20;
}

public class GetRecentAdminActivitiesQueryHandler : IRequestHandler<GetRecentAdminActivitiesQuery, IReadOnlyList<AdminActivityResponse>>
{
    private readonly IAdminActivityService _adminActivityService;
    private readonly ICurrentUserService _currentUserService;

    public GetRecentAdminActivitiesQueryHandler(
        IAdminActivityService adminActivityService,
        ICurrentUserService currentUserService)
    {
        _adminActivityService = adminActivityService;
        _currentUserService = currentUserService;
    }

public async Task<IReadOnlyList<AdminActivityResponse>> Handle(
        GetRecentAdminActivitiesQuery request,
        CancellationToken cancellationToken)
    {
        var activities = await _adminActivityService.GetRecentAsync(request.Count);
        return activities;
    }
    }

public class GetRecentAdminActivitiesQueryValidator : AbstractValidator<GetRecentAdminActivitiesQuery>
{
    public GetRecentAdminActivitiesQueryValidator()
    {
        RuleFor(x => x.Count)
            .InclusiveBetween(1, 100).WithMessage("{PropertyName} mora biti u dozvoljenom opsegu.");
    }
    }