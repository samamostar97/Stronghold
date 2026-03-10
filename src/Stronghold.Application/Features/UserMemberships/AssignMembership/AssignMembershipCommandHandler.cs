using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.UserMemberships.AssignMembership;

public class AssignMembershipCommandHandler : IRequestHandler<AssignMembershipCommand, UserMembershipResponse>
{
    private readonly IUserMembershipRepository _membershipRepository;
    private readonly IUserRepository _userRepository;
    private readonly IMembershipPackageRepository _packageRepository;

    public AssignMembershipCommandHandler(
        IUserMembershipRepository membershipRepository,
        IUserRepository userRepository,
        IMembershipPackageRepository packageRepository)
    {
        _membershipRepository = membershipRepository;
        _userRepository = userRepository;
        _packageRepository = packageRepository;
    }

    public async Task<UserMembershipResponse> Handle(AssignMembershipCommand request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByIdAsync(request.UserId)
            ?? throw new NotFoundException("Korisnik", request.UserId);

        var package = await _packageRepository.GetByIdAsync(request.MembershipPackageId)
            ?? throw new NotFoundException("Paket članarine", request.MembershipPackageId);

        var activeMembership = await _membershipRepository.GetActiveByUserIdAsync(request.UserId);
        if (activeMembership != null)
            throw new ConflictException("Korisnik već ima aktivnu članarinu.");

        var now = DateTime.UtcNow;
        var membership = new UserMembership
        {
            UserId = request.UserId,
            MembershipPackageId = request.MembershipPackageId,
            StartDate = now,
            EndDate = now.AddDays(30),
            IsActive = true
        };

        await _membershipRepository.AddAsync(membership);
        await _membershipRepository.SaveChangesAsync();

        membership.User = user;
        membership.MembershipPackage = package;

        return UserMembershipMappings.ToResponse(membership);
    }
}
