using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.MembershipPackages.DeleteMembershipPackage;

public class DeleteMembershipPackageCommandHandler : IRequestHandler<DeleteMembershipPackageCommand, Unit>
{
    private readonly IMembershipPackageRepository _repository;
    private readonly IAuditService _auditService;
    private readonly ICurrentUserService _currentUserService;

    public DeleteMembershipPackageCommandHandler(
        IMembershipPackageRepository repository,
        IAuditService auditService,
        ICurrentUserService currentUserService)
    {
        _repository = repository;
        _auditService = auditService;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(DeleteMembershipPackageCommand request, CancellationToken cancellationToken)
    {
        var package = await _repository.GetByIdAsync(request.Id)
            ?? throw new NotFoundException("Paket članarine", request.Id);

        await _auditService.LogDeleteAsync(_currentUserService.UserId, "MembershipPackage", package.Id, package);

        _repository.Remove(package);
        await _repository.SaveChangesAsync();

        return Unit.Value;
    }
}
