using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.UserMemberships.CancelMembership;

public class CancelMembershipCommandHandler : IRequestHandler<CancelMembershipCommand, Unit>
{
    private readonly IUserMembershipRepository _membershipRepository;
    private readonly IUserRepository _userRepository;

    public CancelMembershipCommandHandler(
        IUserMembershipRepository membershipRepository,
        IUserRepository userRepository)
    {
        _membershipRepository = membershipRepository;
        _userRepository = userRepository;
    }

    public async Task<Unit> Handle(CancelMembershipCommand request, CancellationToken cancellationToken)
    {
        _ = await _userRepository.GetByIdAsync(request.UserId)
            ?? throw new NotFoundException("Korisnik", request.UserId);

        var activeMembership = await _membershipRepository.GetActiveByUserIdAsync(request.UserId)
            ?? throw new NotFoundException("Aktivna članarina za korisnika nije pronađena.");

        activeMembership.IsActive = false;
        _membershipRepository.Update(activeMembership);
        await _membershipRepository.SaveChangesAsync();

        return Unit.Value;
    }
}
