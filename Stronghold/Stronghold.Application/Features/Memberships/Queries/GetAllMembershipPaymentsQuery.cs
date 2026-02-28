using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.Common.Authorization;
using Stronghold.Application.Features.Memberships.DTOs;
using Stronghold.Application.IRepositories;

namespace Stronghold.Application.Features.Memberships.Queries;

public class GetAllMembershipPaymentsQuery : IRequest<PagedResult<AdminMembershipPaymentResponse>>, IAuthorizeAdminRequest
{
    public AdminMembershipPaymentsFilter Filter { get; set; } = new();
}

public class GetAllMembershipPaymentsQueryHandler
    : IRequestHandler<GetAllMembershipPaymentsQuery, PagedResult<AdminMembershipPaymentResponse>>
{
    private readonly IMembershipRepository _membershipRepository;

    public GetAllMembershipPaymentsQueryHandler(IMembershipRepository membershipRepository)
    {
        _membershipRepository = membershipRepository;
    }

    public async Task<PagedResult<AdminMembershipPaymentResponse>> Handle(
        GetAllMembershipPaymentsQuery request,
        CancellationToken cancellationToken)
    {
        var filter = request.Filter ?? new AdminMembershipPaymentsFilter();
        var nowUtc = StrongholdTimeUtils.UtcNow;

        var page = await _membershipRepository.GetAllPaymentsPagedAsync(filter, cancellationToken);

        return new PagedResult<AdminMembershipPaymentResponse>
        {
            Items = page.Items.Select(x => new AdminMembershipPaymentResponse
            {
                Id = x.Id,
                UserId = x.UserId,
                UserName = $"{x.User.FirstName} {x.User.LastName}".Trim(),
                UserEmail = x.User.Email,
                MembershipPackageId = x.MembershipPackageId,
                PackageName = x.MembershipPackage?.PackageName ?? string.Empty,
                AmountPaid = x.AmountPaid,
                PaymentDate = x.PaymentDate,
                StartDate = x.StartDate,
                EndDate = x.EndDate,
                IsActive = x.StartDate <= nowUtc && x.EndDate > nowUtc
            }).ToList(),
            TotalCount = page.TotalCount,
            PageNumber = page.PageNumber
        };
    }
}

public class GetAllMembershipPaymentsQueryValidator : AbstractValidator<GetAllMembershipPaymentsQuery>
{
    public GetAllMembershipPaymentsQueryValidator()
    {
        RuleFor(x => x.Filter).NotNull().WithMessage("{PropertyName} je obavezno.");

        RuleFor(x => x.Filter.PageNumber)
            .GreaterThanOrEqualTo(1).WithMessage("{PropertyName} mora biti vece ili jednako dozvoljenoj vrijednosti.");

        RuleFor(x => x.Filter.PageSize)
            .GreaterThanOrEqualTo(1).WithMessage("{PropertyName} mora biti vece ili jednako dozvoljenoj vrijednosti.")
            .LessThanOrEqualTo(200).WithMessage("{PropertyName} mora biti manje ili jednako dozvoljenoj vrijednosti.");

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
        var normalized = orderBy?.Trim().ToLowerInvariant();
        return normalized is
            "date" or "datedesc" or
            "amount" or "amountdesc" or
            "user" or "userdesc" or
            "packagename" or "packagenamedesc" or
            "package" or "packagedesc";
    }
}
