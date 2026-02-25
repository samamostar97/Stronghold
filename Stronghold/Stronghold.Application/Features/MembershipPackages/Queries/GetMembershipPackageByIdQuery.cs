using FluentValidation;
using MediatR;
using Stronghold.Application.Features.MembershipPackages.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.MembershipPackages.Queries;

public class GetMembershipPackageByIdQuery : IRequest<MembershipPackageResponse>, IAuthorizeAdminOrGymMemberRequest
{
    public int Id { get; set; }
}

public class GetMembershipPackageByIdQueryHandler
    : IRequestHandler<GetMembershipPackageByIdQuery, MembershipPackageResponse>
{
    private readonly IMembershipPackageRepository _membershipPackageRepository;

    public GetMembershipPackageByIdQueryHandler(
        IMembershipPackageRepository membershipPackageRepository)
    {
        _membershipPackageRepository = membershipPackageRepository;
    }

public async Task<MembershipPackageResponse> Handle(GetMembershipPackageByIdQuery request, CancellationToken cancellationToken)
    {
        var membershipPackage = await _membershipPackageRepository.GetByIdAsync(request.Id, cancellationToken);
        if (membershipPackage is null)
        {
            throw new KeyNotFoundException($"Paket sa id '{request.Id}' ne postoji.");
        }

        return MapToResponse(membershipPackage);
    }

private static MembershipPackageResponse MapToResponse(MembershipPackage membershipPackage)
    {
        return new MembershipPackageResponse
        {
            Id = membershipPackage.Id,
            PackageName = membershipPackage.PackageName,
            PackagePrice = membershipPackage.PackagePrice,
            Description = membershipPackage.Description,
            CreatedAt = membershipPackage.CreatedAt
        };
    }
    }

public class GetMembershipPackageByIdQueryValidator : AbstractValidator<GetMembershipPackageByIdQuery>
{
    public GetMembershipPackageByIdQueryValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
    }