using MediatR;
using Stronghold.Application.Features.Profiles.DTOs;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Profiles.Queries;

public class GetMyProgressQuery : IRequest<UserProgressResponse>
{
}

public class GetMyProgressQueryHandler : IRequestHandler<GetMyProgressQuery, UserProgressResponse>
{
    private readonly IUserProfileService _userProfileService;
    private readonly ICurrentUserService _currentUserService;

    public GetMyProgressQueryHandler(
        IUserProfileService userProfileService,
        ICurrentUserService currentUserService)
    {
        _userProfileService = userProfileService;
        _currentUserService = currentUserService;
    }

    public async Task<UserProgressResponse> Handle(GetMyProgressQuery request, CancellationToken cancellationToken)
    {
        var userId = EnsureAuthenticatedAccess();
        return await _userProfileService.GetProgressAsync(userId);
    }

    private int EnsureAuthenticatedAccess()
    {
        if (!_currentUserService.IsAuthenticated || _currentUserService.UserId is null)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }

        return _currentUserService.UserId.Value;
    }
}
