using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Configurations;

public class MembershipConfiguration : BaseEntityConfiguration<Membership>
{
    public override void Configure(EntityTypeBuilder<Membership> builder)
    {
        base.Configure(builder);

        builder.Property(m => m.StartDate).IsRequired();
        builder.Property(m => m.EndDate).IsRequired();

        builder.HasOne(m => m.User)
            .WithMany(u => u.Memberships)
            .HasForeignKey(m => m.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(m => m.MembershipPackage)
            .WithMany(mp => mp.Memberships)
            .HasForeignKey(m => m.MembershipPackageId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
