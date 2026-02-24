using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Memberships.Queries;

public class HasActiveMembershipQuery : IRequest<bool>
{
    public int UserId { get; set; }
}

public class HasActiveMembershipQueryHandler : IRequestHandler<HasActiveMembershipQuery, bool>
{
    private readonly IMembershipRepository _membershipRepository;
    private readonly ICurrentUserService _currentUserService;

    public HasActiveMembershipQueryHandler(IMembershipRepository membershipRepository, ICurrentUserService currentUserService)
    {
        _membershipRepository = membershipRepository;
        _currentUserService = currentUserService;
    }

    public async Task<bool> Handle(HasActiveMembershipQuery request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

        var userExists = await _membershipRepository.UserExistsAsync(request.UserId, cancellationToken);
        if (!userExists)
        {
            return false;
        }

        var nowUtc = StrongholdTimeUtils.UtcNow;
        return await _membershipRepository.HasActiveMembershipAsync(request.UserId, nowUtc, cancellationToken);
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

public class HasActiveMembershipQueryValidator : AbstractValidator<HasActiveMembershipQuery>
{
    public HasActiveMembershipQueryValidator()
    {
        RuleFor(x => x.UserId).GreaterThan(0);
    }
}
