using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.MembershipPackages.UpdateMembershipPackage;

public class UpdateMembershipPackageCommandHandler : IRequestHandler<UpdateMembershipPackageCommand, MembershipPackageResponse>
{
    private readonly IMembershipPackageRepository _repository;

    public UpdateMembershipPackageCommandHandler(IMembershipPackageRepository repository)
    {
        _repository = repository;
    }

    public async Task<MembershipPackageResponse> Handle(UpdateMembershipPackageCommand request, CancellationToken cancellationToken)
    {
        var package = await _repository.GetByIdAsync(request.Id)
            ?? throw new NotFoundException("Paket članarine", request.Id);

        package.Name = request.Name;
        package.Description = request.Description;
        package.Price = request.Price;

        _repository.Update(package);
        await _repository.SaveChangesAsync();

        return MembershipPackageMappings.ToResponse(package);
    }
}
