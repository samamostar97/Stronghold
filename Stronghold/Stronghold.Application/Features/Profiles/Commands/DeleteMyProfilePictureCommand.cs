using MediatR;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Profiles.Commands;

public class DeleteMyProfilePictureCommand : IRequest<Unit>, IAuthorizeAuthenticatedRequest
{
}

public class DeleteMyProfilePictureCommandHandler : IRequestHandler<DeleteMyProfilePictureCommand, Unit>
{
    private readonly IUserProfileService _userProfileService;
    private readonly ICurrentUserService _currentUserService;

    public DeleteMyProfilePictureCommandHandler(
        IUserProfileService userProfileService,
        ICurrentUserService currentUserService)
    {
        _userProfileService = userProfileService;
        _currentUserService = currentUserService;
    }

public async Task<Unit> Handle(DeleteMyProfilePictureCommand request, CancellationToken cancellationToken)
    {
        var userId = _currentUserService.UserId!.Value;
        await _userProfileService.DeleteProfilePictureAsync(userId);
        return Unit.Value;
    }
    }