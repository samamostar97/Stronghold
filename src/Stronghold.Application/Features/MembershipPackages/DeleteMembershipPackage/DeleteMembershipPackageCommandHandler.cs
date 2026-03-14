using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.MembershipPackages.DeleteMembershipPackage;

public class DeleteMembershipPackageCommandHandler : IRequestHandler<DeleteMembershipPackageCommand, Unit>
{
    private readonly IMembershipPackageRepository _repository;
    private readonly IUserMembershipRepository _membershipRepository;
    private readonly IAuditService _auditService;
    private readonly ICurrentUserService _currentUserService;

    public DeleteMembershipPackageCommandHandler(
        IMembershipPackageRepository repository,
        IUserMembershipRepository membershipRepository,
        IAuditService auditService,
        ICurrentUserService currentUserService)
    {
        _repository = repository;
        _membershipRepository = membershipRepository;
        _auditService = auditService;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(DeleteMembershipPackageCommand request, CancellationToken cancellationToken)
    {
        var package = await _repository.GetByIdAsync(request.Id)
            ?? throw new NotFoundException("Paket članarine", request.Id);

        var hasActiveMemberships = await _membershipRepository.Query()
            .AnyAsync(m => m.MembershipPackageId == request.Id && m.IsActive, cancellationToken);
        if (hasActiveMemberships)
            throw new ConflictException("Nije moguće obrisati paket koji ima aktivne članarine.");

        await _auditService.LogDeleteAsync(_currentUserService.UserId, "MembershipPackage", package.Id, package);

        _repository.Remove(package);
        await _repository.SaveChangesAsync();

        return Unit.Value;
    }
}
