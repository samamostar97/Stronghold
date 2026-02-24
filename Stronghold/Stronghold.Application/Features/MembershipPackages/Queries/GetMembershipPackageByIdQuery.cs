using FluentValidation;
using MediatR;
using Stronghold.Application.Features.MembershipPackages.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.MembershipPackages.Queries;

public class GetMembershipPackageByIdQuery : IRequest<MembershipPackageResponse>
{
    public int Id { get; set; }
}

public class GetMembershipPackageByIdQueryHandler
    : IRequestHandler<GetMembershipPackageByIdQuery, MembershipPackageResponse>
{
    private readonly IMembershipPackageRepository _membershipPackageRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetMembershipPackageByIdQueryHandler(
        IMembershipPackageRepository membershipPackageRepository,
        ICurrentUserService currentUserService)
    {
        _membershipPackageRepository = membershipPackageRepository;
        _currentUserService = currentUserService;
    }

    public async Task<MembershipPackageResponse> Handle(GetMembershipPackageByIdQuery request, CancellationToken cancellationToken)
    {
        EnsureReadAccess();

        var membershipPackage = await _membershipPackageRepository.GetByIdAsync(request.Id, cancellationToken);
        if (membershipPackage is null)
        {
            throw new KeyNotFoundException($"Paket sa id '{request.Id}' ne postoji.");
        }

        return MapToResponse(membershipPackage);
    }

    private void EnsureReadAccess()
    {
        if (!_currentUserService.IsAuthenticated || _currentUserService.UserId is null)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }

        if (!_currentUserService.IsInRole("Admin") && !_currentUserService.IsInRole("GymMember"))
        {
            throw new UnauthorizedAccessException("Nemate dozvolu za ovu akciju.");
        }
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

