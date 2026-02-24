using FluentValidation;
using MediatR;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Profiles.Queries;

public class GetLeaderboardQuery : IRequest<IReadOnlyList<LeaderboardEntryResponse>>
{
    public int Top { get; set; } = 5;
}

public class GetLeaderboardQueryHandler : IRequestHandler<GetLeaderboardQuery, IReadOnlyList<LeaderboardEntryResponse>>
{
    private readonly IUserProfileService _userProfileService;
    private readonly ICurrentUserService _currentUserService;

    public GetLeaderboardQueryHandler(
        IUserProfileService userProfileService,
        ICurrentUserService currentUserService)
    {
        _userProfileService = userProfileService;
        _currentUserService = currentUserService;
    }

    public async Task<IReadOnlyList<LeaderboardEntryResponse>> Handle(GetLeaderboardQuery request, CancellationToken cancellationToken)
    {
        EnsureAuthenticatedAccess();
        var leaderboard = await _userProfileService.GetLeaderboardAsync(request.Top);
        return leaderboard;
    }

    private void EnsureAuthenticatedAccess()
    {
        if (!_currentUserService.IsAuthenticated || _currentUserService.UserId is null)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }
    }
}

public class GetLeaderboardQueryValidator : AbstractValidator<GetLeaderboardQuery>
{
    public GetLeaderboardQueryValidator()
    {
        RuleFor(x => x.Top)
            .InclusiveBetween(1, 100);
    }
}
