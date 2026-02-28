using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Reports.DTOs;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Reports.Queries;

public class GetActivityFeedQuery : IRequest<IReadOnlyList<ActivityFeedItemResponse>>, IAuthorizeAdminRequest
{
    public int Count { get; set; } = 20;
}

public class GetActivityFeedQueryHandler : IRequestHandler<GetActivityFeedQuery, IReadOnlyList<ActivityFeedItemResponse>>
{
    private readonly IReportReadService _reportService;

    public GetActivityFeedQueryHandler(IReportReadService reportService)
    {
        _reportService = reportService;
    }

    public async Task<IReadOnlyList<ActivityFeedItemResponse>> Handle(GetActivityFeedQuery request, CancellationToken cancellationToken)
    {
        var feed = await _reportService.GetActivityFeedAsync(request.Count);
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
