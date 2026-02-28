using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Dashboard.DTOs;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Dashboard.Queries;

public class GetActivityFeedQuery : IRequest<IReadOnlyList<ActivityFeedItemResponse>>, IAuthorizeAdminRequest
{
    public int Count { get; set; } = 20;
}

public class GetActivityFeedQueryHandler : IRequestHandler<GetActivityFeedQuery, IReadOnlyList<ActivityFeedItemResponse>>
{
    private readonly IDashboardReadService _dashboardService;

    public GetActivityFeedQueryHandler(IDashboardReadService dashboardService)
    {
        _dashboardService = dashboardService;
    }

    public async Task<IReadOnlyList<ActivityFeedItemResponse>> Handle(GetActivityFeedQuery request, CancellationToken cancellationToken)
    {
        var feed = await _dashboardService.GetActivityFeedAsync(request.Count);
        return feed;
    }
}

public class GetActivityFeedQueryValidator : AbstractValidator<GetActivityFeedQuery>
{
    public GetActivityFeedQueryValidator()
    {
        RuleFor(x => x.Count)
            .InclusiveBetween(1, 100).WithMessage("{PropertyName} mora biti u dozvoljenom opsegu.");
    }
}
