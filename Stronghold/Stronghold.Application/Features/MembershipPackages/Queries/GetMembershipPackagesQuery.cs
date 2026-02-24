using FluentValidation;
using MediatR;
using Stronghold.Application.Features.MembershipPackages.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.MembershipPackages.Queries;

public class GetMembershipPackagesQuery : IRequest<IReadOnlyList<MembershipPackageResponse>>
{
    public MembershipPackageFilter Filter { get; set; } = new();
}

public class GetMembershipPackagesQueryHandler
    : IRequestHandler<GetMembershipPackagesQuery, IReadOnlyList<MembershipPackageResponse>>
{
    private readonly IMembershipPackageRepository _membershipPackageRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetMembershipPackagesQueryHandler(
        IMembershipPackageRepository membershipPackageRepository,
        ICurrentUserService currentUserService)
    {
        _membershipPackageRepository = membershipPackageRepository;
        _currentUserService = currentUserService;
    }

    public async Task<IReadOnlyList<MembershipPackageResponse>> Handle(
        GetMembershipPackagesQuery request,
        CancellationToken cancellationToken)
    {
        EnsureReadAccess();

        var filter = request.Filter ?? new MembershipPackageFilter();
        filter.PageNumber = 1;
        filter.PageSize = int.MaxValue;

        var page = await _membershipPackageRepository.GetPagedAsync(filter, cancellationToken);
        return page.Items.Select(MapToResponse).ToList();
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

public class GetMembershipPackagesQueryValidator : AbstractValidator<GetMembershipPackagesQuery>
{
    public GetMembershipPackagesQueryValidator()
    {
        RuleFor(x => x.Filter).NotNull().WithMessage("{PropertyName} je obavezno.");

        RuleFor(x => x.Filter.Search)
            .MaximumLength(200).WithMessage("{PropertyName} ne smije imati vise od 200 karaktera.")
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.Search));

        RuleFor(x => x.Filter.OrderBy)
            .MaximumLength(30).WithMessage("{PropertyName} ne smije imati vise od 30 karaktera.")
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.OrderBy));

        RuleFor(x => x.Filter.OrderBy)
            .Must(BeValidOrderBy)
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.OrderBy))
            .WithMessage("Neispravna vrijednost za sortiranje.");
    }

    private static bool BeValidOrderBy(string? orderBy)
    {
        var value = orderBy?.Trim().ToLowerInvariant();
        return value is
            "packagename" or
            "packagenamedesc" or
            "priceasc" or
            "pricedesc" or
            "createdat" or
            "createdatdesc";
    }
}

