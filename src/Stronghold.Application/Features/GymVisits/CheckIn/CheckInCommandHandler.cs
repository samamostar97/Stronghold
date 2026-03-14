using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.GymVisits.CheckIn;

public class CheckInCommandHandler : IRequestHandler<CheckInCommand, GymVisitResponse>
{
    private readonly IGymVisitRepository _gymVisitRepository;
    private readonly IUserRepository _userRepository;
    private readonly IUserMembershipRepository _membershipRepository;

    public CheckInCommandHandler(
        IGymVisitRepository gymVisitRepository,
        IUserRepository userRepository,
        IUserMembershipRepository membershipRepository)
    {
        _gymVisitRepository = gymVisitRepository;
        _userRepository = userRepository;
        _membershipRepository = membershipRepository;
    }

    public async Task<GymVisitResponse> Handle(CheckInCommand request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByIdAsync(request.UserId)
            ?? throw new NotFoundException("Korisnik", request.UserId);

        var activeMembership = await _membershipRepository.GetActiveByUserIdAsync(request.UserId)
            ?? throw new InvalidOperationException("Korisnik nema aktivnu članarinu.");

        var activeVisit = await _gymVisitRepository.GetActiveByUserIdAsync(request.UserId);
        if (activeVisit != null)
            throw new ConflictException("Korisnik je već prijavljen u teretani.");

        var visit = new GymVisit
        {
            UserId = request.UserId,
            UserFullName = $"{user.FirstName} {user.LastName}",
            Username = user.Username,
            CheckInAt = DateTime.UtcNow
        };

        await _gymVisitRepository.AddAsync(visit);
        await _gymVisitRepository.SaveChangesAsync();

        visit.User = user;

        return GymVisitMappings.ToResponse(visit);
    }
}
