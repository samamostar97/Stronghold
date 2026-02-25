using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.IRepositories;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Memberships.Commands;

public class RevokeMembershipCommand : IRequest<bool>, IAuthorizeAdminRequest
{
    public int UserId { get; set; }
}

public class RevokeMembershipCommandHandler : IRequestHandler<RevokeMembershipCommand, bool>
{
    private readonly IMembershipRepository _membershipRepository;

    public RevokeMembershipCommandHandler(IMembershipRepository membershipRepository)
    {
        _membershipRepository = membershipRepository;
    }

public async Task<bool> Handle(RevokeMembershipCommand request, CancellationToken cancellationToken)
    {
        var nowUtc = StrongholdTimeUtils.UtcNow;
        var userExists = await _membershipRepository.UserExistsAsync(request.UserId, cancellationToken);
        if (!userExists)
        {
            throw new KeyNotFoundException("Korisnik ne postoji.");
        }

        var activeMembership = await _membershipRepository.GetActiveMembershipAsync(request.UserId, nowUtc, cancellationToken);
        var activePaymentHistories = await _membershipRepository.GetActivePaymentHistoriesAsync(request.UserId, nowUtc, cancellationToken);

        if (activeMembership is null && activePaymentHistories.Count == 0)
        {
            throw new InvalidOperationException("Korisnik nema aktivnu clanarinu.");
        }

        if (activeMembership is not null)
        {
            activeMembership.IsDeleted = true;
            activeMembership.EndDate = nowUtc;
            await _membershipRepository.UpdateMembershipAsync(activeMembership, cancellationToken);
        }

        if (activePaymentHistories.Count > 0)
        {
            foreach (var paymentHistory in activePaymentHistories)
            {
                paymentHistory.EndDate = nowUtc;
            }

            await _membershipRepository.UpdatePaymentHistoryRangeAsync(activePaymentHistories, cancellationToken);
        }

        return true;
    }
    }

public class RevokeMembershipCommandValidator : AbstractValidator<RevokeMembershipCommand>
{
    public RevokeMembershipCommandValidator()
    {
        RuleFor(x => x.UserId).GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
    }