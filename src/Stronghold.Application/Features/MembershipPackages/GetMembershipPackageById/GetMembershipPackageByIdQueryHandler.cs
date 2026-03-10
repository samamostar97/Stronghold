using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.MembershipPackages.GetMembershipPackageById;

public class GetMembershipPackageByIdQueryHandler : IRequestHandler<GetMembershipPackageByIdQuery, MembershipPackageResponse>
{
    private readonly IMembershipPackageRepository _repository;

    public GetMembershipPackageByIdQueryHandler(IMembershipPackageRepository repository)
    {
        _repository = repository;
    }

    public async Task<MembershipPackageResponse> Handle(GetMembershipPackageByIdQuery request, CancellationToken cancellationToken)
    {
        var package = await _repository.GetByIdAsync(request.Id)
            ?? throw new NotFoundException("Paket članarine", request.Id);

        return MembershipPackageMappings.ToResponse(package);
    }
}
