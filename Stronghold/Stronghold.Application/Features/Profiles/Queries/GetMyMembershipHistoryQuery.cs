using MediatR;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Profiles.Queries;

public class GetMyMembershipHistoryQuery : IRequest<IReadOnlyList<MembershipPaymentResponse>>
{
}

public class GetMyMembershipHistoryQueryHandler : IRequestHandler<GetMyMembershipHistoryQuery, IReadOnlyList<MembershipPaymentResponse>>
{
    private readonly IUserProfileService _userProfileService;
    private readonly ICurrentUserService _currentUserService;

    public GetMyMembershipHistoryQueryHandler(
        IUserProfileService userProfileService,
        ICurrentUserService currentUserService)
    {
        _userProfileService = userProfileService;
        _currentUserService = currentUserService;
    }

    public async Task<IReadOnlyList<MembershipPaymentResponse>> Handle(
        GetMyMembershipHistoryQuery request,
        CancellationToken cancellationToken)
    {
        var userId = EnsureAuthenticatedAccess();
        var history = await _userProfileService.GetMembershipPaymentHistoryAsync(userId);
        return history.ToList();
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
