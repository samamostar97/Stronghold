using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Configurations;

public class SupplementCategoryConfiguration : BaseEntityConfiguration<SupplementCategory>
{
    public override void Configure(EntityTypeBuilder<SupplementCategory> builder)
    {
        base.Configure(builder);

        builder.Property(c => c.Name).HasMaxLength(100).IsRequired();

        builder.HasIndex(c => c.Name)
            .IsUnique()
            .HasFilter("[IsDeleted] = 0");
    }
}
