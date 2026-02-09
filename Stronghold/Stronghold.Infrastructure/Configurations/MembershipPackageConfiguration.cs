using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Configurations;

public class MembershipPackageConfiguration : BaseEntityConfiguration<MembershipPackage>
{
    public override void Configure(EntityTypeBuilder<MembershipPackage> builder)
    {
        base.Configure(builder);

        builder.Property(m => m.PackageName).HasMaxLength(100).IsRequired();
        builder.Property(m => m.PackagePrice).HasPrecision(18, 2).IsRequired();
        builder.Property(m => m.Description).HasMaxLength(500).IsRequired();

    }
}
