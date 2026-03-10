using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.MembershipPackages.DeleteMembershipPackage;

public class DeleteMembershipPackageCommandHandler : IRequestHandler<DeleteMembershipPackageCommand, Unit>
{
    private readonly IMembershipPackageRepository _repository;

    public DeleteMembershipPackageCommandHandler(IMembershipPackageRepository repository)
    {
        _repository = repository;
    }

    public async Task<Unit> Handle(DeleteMembershipPackageCommand request, CancellationToken cancellationToken)
    {
        var package = await _repository.GetByIdAsync(request.Id)
            ?? throw new NotFoundException("Paket članarine", request.Id);

        _repository.Remove(package);
        await _repository.SaveChangesAsync();

        return Unit.Value;
    }
}
