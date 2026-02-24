using MediatR;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Profiles.Commands;

public class DeleteMyProfilePictureCommand : IRequest<Unit>
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
        var userId = EnsureAuthenticatedAccess();
        await _userProfileService.DeleteProfilePictureAsync(userId);
        return Unit.Value;
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
