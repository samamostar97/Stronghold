using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Configurations;

public class MembershipPackageConfiguration : BaseEntityConfiguration<MembershipPackage>
{
    public override void Configure(EntityTypeBuilder<MembershipPackage> builder)
    {
        base.Configure(builder);

        builder.Property(m => m.Name).HasMaxLength(100).IsRequired();
        builder.Property(m => m.Price).HasPrecision(18, 2).IsRequired();
        builder.Property(m => m.Description).HasMaxLength(500);
        builder.Property(m => m.StartDate).IsRequired();
        builder.Property(m => m.EndDate).IsRequired();

        builder.HasOne(m => m.User)
            .WithOne(u => u.MembershipPackage)
            .HasForeignKey<MembershipPackage>(m => m.UserId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
