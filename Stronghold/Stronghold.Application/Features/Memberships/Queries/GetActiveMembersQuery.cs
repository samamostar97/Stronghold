using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Memberships.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Memberships.Queries;

public class GetActiveMembersQuery : IRequest<PagedResult<ActiveMemberResponse>>
{
    public ActiveMemberFilter Filter { get; set; } = new();
}

public class GetActiveMembersQueryHandler : IRequestHandler<GetActiveMembersQuery, PagedResult<ActiveMemberResponse>>
{
    private readonly IMembershipRepository _membershipRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetActiveMembersQueryHandler(IMembershipRepository membershipRepository, ICurrentUserService currentUserService)
    {
        _membershipRepository = membershipRepository;
        _currentUserService = currentUserService;
    }

    public async Task<PagedResult<ActiveMemberResponse>> Handle(GetActiveMembersQuery request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

        var filter = request.Filter ?? new ActiveMemberFilter();
        var nowUtc = StrongholdTimeUtils.UtcNow;
        var page = await _membershipRepository.GetActiveMembersPagedAsync(filter, nowUtc, cancellationToken);

        return new PagedResult<ActiveMemberResponse>
        {
            Items = page.Items.Select(x => new ActiveMemberResponse
            {
                UserId = x.UserId,
                FirstName = x.User?.FirstName ?? string.Empty,
                LastName = x.User?.LastName ?? string.Empty,
                Username = x.User?.Username ?? string.Empty,
                ProfileImageUrl = x.User?.ProfileImageUrl,
                PackageName = x.MembershipPackage?.PackageName ?? string.Empty,
                MembershipEndDate = x.EndDate
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

public class GetActiveMembersQueryValidator : AbstractValidator<GetActiveMembersQuery>
{
    public GetActiveMembersQueryValidator()
    {
        RuleFor(x => x.Filter).NotNull().WithMessage("{PropertyName} je obavezno.");

        RuleFor(x => x.Filter.PageNumber)
            .GreaterThanOrEqualTo(1).WithMessage("{PropertyName} mora biti vece ili jednako dozvoljenoj vrijednosti.");

        RuleFor(x => x.Filter.PageSize)
            .GreaterThanOrEqualTo(1).WithMessage("{PropertyName} mora biti vece ili jednako dozvoljenoj vrijednosti.")
            .LessThanOrEqualTo(100).WithMessage("{PropertyName} mora biti manje ili jednako dozvoljenoj vrijednosti.");

        RuleFor(x => x.Filter.Name)
            .MaximumLength(200).WithMessage("{PropertyName} ne smije imati vise od 200 karaktera.")
            .When(x => !string.IsNullOrWhiteSpace(x.Filter.Name));
    }
}

