using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.Features.MembershipPackages.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.MembershipPackages.Queries;

public class GetPagedMembershipPackagesQuery : IRequest<PagedResult<MembershipPackageResponse>>, IAuthorizeAdminOrGymMemberRequest
{
    public MembershipPackageFilter Filter { get; set; } = new();
}

public class GetPagedMembershipPackagesQueryHandler
    : IRequestHandler<GetPagedMembershipPackagesQuery, PagedResult<MembershipPackageResponse>>
{
    private readonly IMembershipPackageRepository _membershipPackageRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetPagedMembershipPackagesQueryHandler(
        IMembershipPackageRepository membershipPackageRepository,
        ICurrentUserService currentUserService)
    {
        _membershipPackageRepository = membershipPackageRepository;
        _currentUserService = currentUserService;
    }

public async Task<PagedResult<MembershipPackageResponse>> Handle(
        GetPagedMembershipPackagesQuery request,
        CancellationToken cancellationToken)
    {
        var filter = request.Filter ?? new MembershipPackageFilter();
        var page = await _membershipPackageRepository.GetPagedAsync(filter, cancellationToken);

        return new PagedResult<MembershipPackageResponse>
        {
            Items = page.Items.Select(MapToResponse).ToList(),
            TotalCount = page.TotalCount,
            PageNumber = page.PageNumber
        };
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

public class GetPagedMembershipPackagesQueryValidator : AbstractValidator<GetPagedMembershipPackagesQuery>
{
    public GetPagedMembershipPackagesQueryValidator()
    {
        RuleFor(x => x.Filter).NotNull().WithMessage("{PropertyName} je obavezno.");

        RuleFor(x => x.Filter.PageNumber)
            .GreaterThanOrEqualTo(1).WithMessage("{PropertyName} mora biti vece ili jednako dozvoljenoj vrijednosti.");

        RuleFor(x => x.Filter.PageSize)
            .GreaterThanOrEqualTo(1).WithMessage("{PropertyName} mora biti vece ili jednako dozvoljenoj vrijednosti.")
            .LessThanOrEqualTo(100).WithMessage("{PropertyName} mora biti manje ili jednako dozvoljenoj vrijednosti.");

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