using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.Memberships;
using Stronghold.Application.DTOs.Messaging;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Interfaces;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Services;

public class MembershipService : BaseService<Membership, MembershipResponse, MembershipSearch>, IMembershipService
{
    private readonly IEmailPublisher _emailPublisher;

    public MembershipService(StrongholdDbContext db, IEmailPublisher emailPublisher) : base(db)
    {
        _emailPublisher = emailPublisher;
    }

    protected override IQueryable<Membership> ApplyFilter(IQueryable<Membership> query, MembershipSearch search)
    {
        if (search.UserId.HasValue)
        {
            query = query.Where(m => m.UserId == search.UserId);
        }
        if (!string.IsNullOrWhiteSpace(search.Text))
        {
            var text = search.Text.Trim();
            query = query.Where(m =>
                m.User.FirstName.Contains(text) ||
                m.User.LastName.Contains(text) ||
                m.User.Username.Contains(text));
        }
        if (search.OnlyActive == true)
        {
            var now = DateTime.UtcNow;
            query = query.Where(m => !m.IsRevoked && m.StartDate <= now && m.EndDate > now);
        }
        return query.OrderByDescending(m => m.EndDate);
    }

    public async Task<ActiveMembershipInfo> GetActiveForUserAsync(int userId)
    {
        var now = DateTime.UtcNow;
        // isti filter kao produzenje u AssignAsync - najkasniji istek neukinute clanarine
        var current = await Db.Memberships.AsNoTracking()
            .Where(m => m.UserId == userId && !m.IsRevoked && m.EndDate > now)
            .OrderByDescending(m => m.EndDate)
            .Select(m => new { PackageName = m.Package.Name, m.EndDate })
            .FirstOrDefaultAsync();

        return current == null
            ? new ActiveMembershipInfo()
            : new ActiveMembershipInfo
            {
                HasActive = true,
                PackageName = current.PackageName,
                EndDate = current.EndDate
            };
    }

    public async Task<MembershipResponse> AssignAsync(MembershipAssignRequest request)
    {
        var user = await Db.Users.FindAsync(request.UserId)
            ?? throw new NotFoundException("Odabrani korisnik ne postoji.");
        if (user.Role != UserRole.GymMember)
        {
            throw new BusinessException("Članarina se može dodijeliti samo članovima teretane.");
        }

        var package = await Db.MembershipPackages.FindAsync(request.PackageId)
            ?? throw new NotFoundException("Odabrani paket ne postoji.");

        var now = DateTime.UtcNow;

        // produzenje: nova clanarina krece od isteka trenutno aktivne, inace odmah
        var currentEnd = await Db.Memberships
            .Where(m => m.UserId == user.Id && !m.IsRevoked && m.EndDate > now)
            .MaxAsync(m => (DateTime?)m.EndDate);
        var start = currentEnd ?? now;

        // cijenu i trajanje odredjuje server iz paketa - klijentu se ne vjeruje
        var membership = new Membership
        {
            UserId = user.Id,
            PackageId = package.Id,
            StartDate = start,
            EndDate = start.AddDays(package.DurationDays)
        };
        membership.Payments.Add(new Payment { Amount = package.Price, PaidAt = now });

        Db.Memberships.Add(membership);
        Db.Notifications.Add(new Notification
        {
            UserId = user.Id,
            Title = "Uplata evidentirana",
            Message = $"Uplata od {package.Price:F2} KM je evidentirana - članarina " +
                      $"\"{package.Name}\" vrijedi do {membership.EndDate:dd.MM.yyyy}.",
            Type = NotificationType.PaymentConfirmed,
            CreatedAt = now
        });
        await Db.SaveChangesAsync();

        _emailPublisher.Publish(new EmailMessage
        {
            To = user.Email,
            Subject = "Stronghold - članarina aktivirana",
            Body = $"Poštovani {user.FirstName},\n\nvaša uplata od {package.Price:F2} KM je evidentirana. " +
                   $"Članarina \"{package.Name}\" vrijedi do {membership.EndDate:dd.MM.yyyy}.\n\nVaš Stronghold"
        });
        return await GetByIdAsync(membership.Id);
    }

    public async Task<MembershipResponse> RevokeAsync(int id, MembershipRevokeRequest request)
    {
        var membership = await Db.Memberships.FindAsync(id)
            ?? throw new NotFoundException("Članarina ne postoji.");

        if (membership.IsRevoked)
        {
            throw new BusinessException("Članarina je već ukinuta.");
        }
        if (membership.EndDate <= DateTime.UtcNow)
        {
            throw new BusinessException("Istekla članarina se ne može ukinuti.");
        }

        membership.IsRevoked = true;
        membership.RevokedAt = DateTime.UtcNow;
        membership.RevocationReason = request.Reason;
        await Db.SaveChangesAsync();
        return await GetByIdAsync(id);
    }
}
