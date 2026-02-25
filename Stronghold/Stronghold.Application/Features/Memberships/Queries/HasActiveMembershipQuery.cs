using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.IRepositories;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Memberships.Queries;

public class HasActiveMembershipQuery : IRequest<bool>, IAuthorizeAdminRequest
{
    public int UserId { get; set; }
}

public class HasActiveMembershipQueryHandler : IRequestHandler<HasActiveMembershipQuery, bool>
{
    private readonly IMembershipRepository _membershipRepository;

    public HasActiveMembershipQueryHandler(IMembershipRepository membershipRepository)
    {
        _membershipRepository = membershipRepository;
    }

public async Task<bool> Handle(HasActiveMembershipQuery request, CancellationToken cancellationToken)
    {
        var userExists = await _membershipRepository.UserExistsAsync(request.UserId, cancellationToken);
        if (!userExists)
        {
            return false;
        }

        var nowUtc = StrongholdTimeUtils.UtcNow;
        return await _membershipRepository.HasActiveMembershipAsync(request.UserId, nowUtc, cancellationToken);
    }
    }

public class HasActiveMembershipQueryValidator : AbstractValidator<HasActiveMembershipQuery>
{
    public HasActiveMembershipQueryValidator()
    {
        RuleFor(x => x.UserId).GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
    }