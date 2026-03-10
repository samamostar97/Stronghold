using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.UserMemberships.GetUserMembership;

public class GetUserMembershipQueryHandler : IRequestHandler<GetUserMembershipQuery, UserMembershipResponse?>
{
    private readonly IUserMembershipRepository _membershipRepository;
    private readonly IUserRepository _userRepository;

    public GetUserMembershipQueryHandler(
        IUserMembershipRepository membershipRepository,
        IUserRepository userRepository)
    {
        _membershipRepository = membershipRepository;
        _userRepository = userRepository;
    }

    public async Task<UserMembershipResponse?> Handle(GetUserMembershipQuery request, CancellationToken cancellationToken)
    {
        _ = await _userRepository.GetByIdAsync(request.UserId)
            ?? throw new NotFoundException("Korisnik", request.UserId);

        var membership = await _membershipRepository.GetActiveByUserIdAsync(request.UserId);
        if (membership == null)
            return null;

        return UserMembershipMappings.ToResponse(membership);
    }
}
