using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Memberships.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Memberships.Queries;

public class GetMembershipPaymentsQuery : IRequest<PagedResult<MembershipPaymentResponse>>
{
    public int UserId { get; set; }
    public MembershipPaymentFilter Filter { get; set; } = new();
}

public class GetMembershipPaymentsQueryHandler : IRequestHandler<GetMembershipPaymentsQuery, PagedResult<MembershipPaymentResponse>>
{
    private readonly IMembershipRepository _membershipRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetMembershipPaymentsQueryHandler(IMembershipRepository membershipRepository, ICurrentUserService currentUserService)
    {
        _membershipRepository = membershipRepository;
        _currentUserService = currentUserService;
    }

    public async Task<PagedResult<MembershipPaymentResponse>> Handle(GetMembershipPaymentsQuery request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

        var filter = request.Filter ?? new MembershipPaymentFilter();
        var userExists = await _membershipRepository.UserExistsAsync(request.UserId, cancellationToken);
        if (!userExists)
        {
            return new PagedResult<MembershipPaymentResponse>
            {
                Items = new List<MembershipPaymentResponse>(),
                TotalCount = 0,
                PageNumber = filter.PageNumber
            };
        }

        var page = await _membershipRepository.GetPaymentsPagedAsync(request.UserId, filter, cancellationToken);

        return new PagedResult<MembershipPaymentResponse>
        {
            Items = page.Items.Select(x => new MembershipPaymentResponse
            {
                Id = x.Id,
                MembershipPackageId = x.MembershipPackageId,
                PackageName = x.MembershipPackage?.PackageName ?? string.Empty,
                AmountPaid = x.AmountPaid,
                PaymentDate = x.PaymentDate,
                StartDate = x.StartDate,
                EndDate = x.EndDate
            }).ToList(),
            TotalCount = page.TotalCount,
            PageNumber = page.PageNumber
        };
    }

    private void EnsureAdminAccess()
    {
        if (!_currentUserService.IsAuthenticated || _currentUserService.UserId is null)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }

        if (!_currentUserService.IsInRole("Admin"))
        {
            throw new UnauthorizedAccessException("Nemate dozvolu za ovu akciju.");
        }
    }
}

public class GetMembershipPaymentsQueryValidator : AbstractValidator<GetMembershipPaymentsQuery>
{
    public GetMembershipPaymentsQueryValidator()
    {
        RuleFor(x => x.UserId).GreaterThan(0);

        RuleFor(x => x.Filter).NotNull();

        RuleFor(x => x.Filter.PageNumber)
            .GreaterThanOrEqualTo(1);

        RuleFor(x => x.Filter.PageSize)
            .GreaterThanOrEqualTo(1)
            .LessThanOrEqualTo(100);

        RuleFor(x => x.Filter.OrderBy)
            .MaximumLength(30)
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.OrderBy));

        RuleFor(x => x.Filter.OrderBy)
            .Must(BeValidOrderBy)
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.OrderBy))
            .WithMessage("Neispravna vrijednost za sortiranje.");
    }

    private static bool BeValidOrderBy(string? orderBy)
    {
        var normalized = orderBy?.Trim().ToLowerInvariant();
        return normalized is "date" or "datedesc" or "amount" or "amountdesc";
    }
}
