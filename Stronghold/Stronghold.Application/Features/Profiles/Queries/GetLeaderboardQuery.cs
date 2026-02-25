using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Profiles.DTOs;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Profiles.Queries;

public class GetLeaderboardQuery : IRequest<IReadOnlyList<LeaderboardEntryResponse>>, IAuthorizeAuthenticatedRequest
{
    public int Top { get; set; } = 5;
}

public class GetLeaderboardQueryHandler : IRequestHandler<GetLeaderboardQuery, IReadOnlyList<LeaderboardEntryResponse>>
{
    private readonly IUserProfileService _userProfileService;

    public GetLeaderboardQueryHandler(
        IUserProfileService userProfileService)
    {
        _userProfileService = userProfileService;
    }

public async Task<IReadOnlyList<LeaderboardEntryResponse>> Handle(GetLeaderboardQuery request, CancellationToken cancellationToken)
    {
        var leaderboard = await _userProfileService.GetLeaderboardAsync(request.Top);
        return leaderboard;
    }
    }

public class GetLeaderboardQueryValidator : AbstractValidator<GetLeaderboardQuery>
{
    public GetLeaderboardQueryValidator()
    {
        RuleFor(x => x.Top)
            .InclusiveBetween(1, 100).WithMessage("{PropertyName} mora biti u dozvoljenom opsegu.");
    }
    }