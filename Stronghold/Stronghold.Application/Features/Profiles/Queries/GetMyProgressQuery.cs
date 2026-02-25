using MediatR;
using Stronghold.Application.Features.Profiles.DTOs;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Profiles.Queries;

public class GetMyProgressQuery : IRequest<UserProgressResponse>, IAuthorizeAuthenticatedRequest
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
        var userId = _currentUserService.UserId!.Value;
        return await _userProfileService.GetProgressAsync(userId);
    }
    }