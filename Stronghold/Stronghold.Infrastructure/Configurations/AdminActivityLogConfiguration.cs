using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Configurations;

public class AdminActivityLogConfiguration : BaseEntityConfiguration<AdminActivityLog>
{
    public override void Configure(EntityTypeBuilder<AdminActivityLog> builder)
    {
        base.Configure(builder);

        builder.Property(x => x.AdminUsername).HasMaxLength(100).IsRequired();
        builder.Property(x => x.ActionType).HasMaxLength(30).IsRequired();
        builder.Property(x => x.EntityType).HasMaxLength(100).IsRequired();
        builder.Property(x => x.Description).HasMaxLength(300).IsRequired();
        builder.Property(x => x.UndoAvailableUntil).IsRequired();

        builder.HasIndex(x => x.CreatedAt);
        builder.HasIndex(x => x.AdminUserId);
        builder.HasIndex(x => x.IsUndone);
        builder.HasIndex(x => x.EntityType);
    }
}
