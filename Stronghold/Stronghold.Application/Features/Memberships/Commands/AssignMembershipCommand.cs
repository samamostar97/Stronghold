using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Memberships.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Application.Features.Memberships.Commands;

public class AssignMembershipCommand : IRequest<MembershipResponse>
{
    public int UserId { get; set; }
    public int MembershipPackageId { get; set; }
    public decimal AmountPaid { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public DateTime PaymentDate { get; set; }
}

public class AssignMembershipCommandHandler : IRequestHandler<AssignMembershipCommand, MembershipResponse>
{
    private readonly IMembershipRepository _membershipRepository;
    private readonly ICurrentUserService _currentUserService;

    public AssignMembershipCommandHandler(IMembershipRepository membershipRepository, ICurrentUserService currentUserService)
    {
        _membershipRepository = membershipRepository;
        _currentUserService = currentUserService;
    }

    public async Task<MembershipResponse> Handle(AssignMembershipCommand request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

        var normalizedStartDate = StrongholdTimeUtils.ToUtcDate(request.StartDate);
        var normalizedEndDate = StrongholdTimeUtils.ToUtcDate(request.EndDate);
        var normalizedPaymentDate = StrongholdTimeUtils.ToUtcDate(request.PaymentDate);

        if (normalizedStartDate.Date < StrongholdTimeUtils.LocalToday.Date)
        {
            throw new ArgumentException("Nije dozvoljeno unijeti datum u proslosti.");
        }

        if (normalizedEndDate < normalizedStartDate)
        {
            throw new ArgumentException("Datum zavrsetka ne moze biti prije datuma pocetka.");
        }

        if (normalizedPaymentDate.Date < normalizedStartDate.Date || normalizedPaymentDate.Date > normalizedEndDate.Date)
        {
            throw new ArgumentException("Datum uplate mora biti unutar perioda clanarine.");
        }

        var userExists = await _membershipRepository.UserExistsAsync(request.UserId, cancellationToken);
        if (!userExists)
        {
            throw new KeyNotFoundException("Korisnik ne postoji.");
        }

        var nowUtc = StrongholdTimeUtils.UtcNow;
        var hasActiveMembership = await _membershipRepository.HasActiveMembershipAsync(request.UserId, nowUtc, cancellationToken);
        if (hasActiveMembership)
        {
            throw new InvalidOperationException("Korisnik vec ima aktivnu clanarinu.");
        }

        var membershipPackageExists = await _membershipRepository.MembershipPackageExistsAsync(request.MembershipPackageId, cancellationToken);
        if (!membershipPackageExists)
        {
            throw new KeyNotFoundException("Paket clanarine ne postoji.");
        }

        var membership = new Membership
        {
            UserId = request.UserId,
            MembershipPackageId = request.MembershipPackageId,
            StartDate = normalizedStartDate,
            EndDate = normalizedEndDate
        };

        var paymentHistory = new MembershipPaymentHistory
        {
            UserId = request.UserId,
            MembershipPackageId = request.MembershipPackageId,
            AmountPaid = request.AmountPaid,
            PaymentDate = normalizedPaymentDate,
            StartDate = normalizedStartDate,
            EndDate = normalizedEndDate
        };

        await _membershipRepository.AddMembershipWithPaymentAsync(membership, paymentHistory, cancellationToken);

        return new MembershipResponse
        {
            Id = membership.Id,
            UserId = membership.UserId,
            MembershipPackageId = membership.MembershipPackageId,
            StartDate = membership.StartDate,
            EndDate = membership.EndDate
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

public class AssignMembershipCommandValidator : AbstractValidator<AssignMembershipCommand>
{
    public AssignMembershipCommandValidator()
    {
        RuleFor(x => x.UserId).GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");

        RuleFor(x => x.MembershipPackageId).GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");

        RuleFor(x => x.AmountPaid)
            .GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.")
            .LessThanOrEqualTo(10000).WithMessage("{PropertyName} mora biti manje ili jednako dozvoljenoj vrijednosti.");

        RuleFor(x => x.StartDate).NotEmpty().WithMessage("{PropertyName} je obavezno.");

        RuleFor(x => x.EndDate).NotEmpty().WithMessage("{PropertyName} je obavezno.");

        RuleFor(x => x.PaymentDate).NotEmpty().WithMessage("{PropertyName} je obavezno.");

        RuleFor(x => x.EndDate)
            .GreaterThanOrEqualTo(x => x.StartDate)
            .WithMessage("Datum zavrsetka ne moze biti prije datuma pocetka.");

        RuleFor(x => x.PaymentDate)
            .Must((model, paymentDate) => paymentDate.Date >= model.StartDate.Date && paymentDate.Date <= model.EndDate.Date)
            .WithMessage("Datum uplate mora biti unutar perioda clanarine.");
    }
}

