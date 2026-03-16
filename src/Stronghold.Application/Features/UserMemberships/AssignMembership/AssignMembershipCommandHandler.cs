using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;
using Stronghold.Domain.Exceptions;
using Stronghold.Application.Common;
using Stronghold.Messaging;

namespace Stronghold.Application.Features.UserMemberships.AssignMembership;

public class AssignMembershipCommandHandler : IRequestHandler<AssignMembershipCommand, UserMembershipResponse>
{
    private readonly IUserMembershipRepository _membershipRepository;
    private readonly IUserRepository _userRepository;
    private readonly IMembershipPackageRepository _packageRepository;
    private readonly IMessagePublisher _messagePublisher;

    public AssignMembershipCommandHandler(
        IUserMembershipRepository membershipRepository,
        IUserRepository userRepository,
        IMembershipPackageRepository packageRepository,
        IMessagePublisher messagePublisher)
    {
        _membershipRepository = membershipRepository;
        _userRepository = userRepository;
        _packageRepository = packageRepository;
        _messagePublisher = messagePublisher;
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
            UserFullName = $"{user.FirstName} {user.LastName}",
            MembershipPackageId = request.MembershipPackageId,
            PackageName = package.Name,
            PackagePrice = package.Price,
            StartDate = now,
            EndDate = now.AddDays(30),
            IsActive = true
        };

        await _membershipRepository.AddAsync(membership);
        await _membershipRepository.SaveChangesAsync();

        membership.User = user;
        membership.MembershipPackage = package;

        await _messagePublisher.PublishAsync(QueueNames.EmailNotifications, EmailTemplates.MembershipAssigned(user.Email, user.FirstName, package.Name, membership.EndDate));

        return UserMembershipMappings.ToResponse(membership);
    }
}
