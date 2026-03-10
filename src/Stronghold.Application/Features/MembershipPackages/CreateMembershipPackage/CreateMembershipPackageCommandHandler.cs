using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;

namespace Stronghold.Application.Features.MembershipPackages.CreateMembershipPackage;

public class CreateMembershipPackageCommandHandler : IRequestHandler<CreateMembershipPackageCommand, MembershipPackageResponse>
{
    private readonly IMembershipPackageRepository _repository;

    public CreateMembershipPackageCommandHandler(IMembershipPackageRepository repository)
    {
        _repository = repository;
    }

    public async Task<MembershipPackageResponse> Handle(CreateMembershipPackageCommand request, CancellationToken cancellationToken)
    {
        var package = new MembershipPackage
        {
            Name = request.Name,
            Description = request.Description,
            Price = request.Price
        };

        await _repository.AddAsync(package);
        await _repository.SaveChangesAsync();

        return MembershipPackageMappings.ToResponse(package);
    }
}
