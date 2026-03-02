using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Configurations;

public class StockLogConfiguration : BaseEntityConfiguration<StockLog>
{
    public override void Configure(EntityTypeBuilder<StockLog> builder)
    {
        base.Configure(builder);

        builder.Property(x => x.Reason).HasMaxLength(50).IsRequired();
        builder.Property(x => x.QuantityChange).IsRequired();
        builder.Property(x => x.QuantityBefore).IsRequired();
        builder.Property(x => x.QuantityAfter).IsRequired();

        builder.HasOne(x => x.Supplement)
            .WithMany()
            .HasForeignKey(x => x.SupplementId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.RelatedOrder)
            .WithMany()
            .HasForeignKey(x => x.RelatedOrderId)
            .OnDelete(DeleteBehavior.SetNull);

        builder.HasOne(x => x.PerformedByUser)
            .WithMany()
            .HasForeignKey(x => x.PerformedByUserId)
            .OnDelete(DeleteBehavior.SetNull);

        builder.HasIndex(x => x.SupplementId);
        builder.HasIndex(x => x.CreatedAt);
    }
}
