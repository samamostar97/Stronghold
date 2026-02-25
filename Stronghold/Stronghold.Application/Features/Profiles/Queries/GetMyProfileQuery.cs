using MediatR;
using Stronghold.Application.Features.Profiles.DTOs;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Profiles.Queries;

public class GetMyProfileQuery : IRequest<UserProfileResponse>, IAuthorizeAuthenticatedRequest
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
        var userId = _currentUserService.UserId!.Value;
        return await _userProfileService.GetProfileAsync(userId);
    }
    }