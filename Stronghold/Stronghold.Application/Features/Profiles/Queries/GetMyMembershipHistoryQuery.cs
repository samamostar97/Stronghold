using MediatR;
using Stronghold.Application.Features.Memberships.DTOs;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Profiles.Queries;

public class GetMyMembershipHistoryQuery : IRequest<IReadOnlyList<MembershipPaymentResponse>>, IAuthorizeAuthenticatedRequest
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
        var userId = _currentUserService.UserId!.Value;
        var history = await _userProfileService.GetMembershipPaymentHistoryAsync(userId);
        return history.ToList();
    }
    }