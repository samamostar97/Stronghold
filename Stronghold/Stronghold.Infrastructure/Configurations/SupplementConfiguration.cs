using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Configurations;

public class SupplementConfiguration : BaseEntityConfiguration<Supplement>
{
    public override void Configure(EntityTypeBuilder<Supplement> builder)
    {
        base.Configure(builder);

        builder.Property(s => s.Name).HasMaxLength(100).IsRequired();
        builder.Property(s => s.Price).HasPrecision(18, 2).IsRequired();
        builder.Property(s => s.Description).HasMaxLength(1000);
        builder.Property(u => u.SupplementImageUrl).HasMaxLength(500);


        builder.HasOne(s => s.SupplementCategory)
            .WithMany(c => c.Supplements)
            .HasForeignKey(s => s.SupplementCategoryId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(s => s.Supplier)
            .WithMany(sup => sup.Supplements)
            .HasForeignKey(s => s.SupplierId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
