using MediatR;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Profiles.Queries;

public class GetMyProfileQuery : IRequest<UserProfileResponse>
{
}

public class GetMyProfileQueryHandler : IRequestHandler<GetMyProfileQuery, UserProfileResponse>
{
    private readonly IUserProfileService _userProfileService;
    private readonly ICurrentUserService _currentUserService;

    public GetMyProfileQueryHandler(
        IUserProfileService userProfileService,
        ICurrentUserService currentUserService)
    {
        _userProfileService = userProfileService;
        _currentUserService = currentUserService;
    }

    public async Task<UserProfileResponse> Handle(GetMyProfileQuery request, CancellationToken cancellationToken)
    {
        var userId = EnsureAuthenticatedAccess();
        return await _userProfileService.GetProfileAsync(userId);
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
