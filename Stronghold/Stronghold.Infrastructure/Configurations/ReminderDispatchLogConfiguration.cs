using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Configurations;

public class ReminderDispatchLogConfiguration : BaseEntityConfiguration<ReminderDispatchLog>
{
    public override void Configure(EntityTypeBuilder<ReminderDispatchLog> builder)
    {
        base.Configure(builder);

        builder.Property(x => x.ReminderType)
            .HasMaxLength(50)
            .IsRequired();

        builder.Property(x => x.EntityType)
            .HasMaxLength(50)
            .IsRequired();

        builder.Property(x => x.EntityId)
            .IsRequired();

        builder.Property(x => x.DaysBeforeEvent)
            .IsRequired();

        builder.Property(x => x.TargetDate)
            .IsRequired();

        builder.HasIndex(x => new
            {
                x.ReminderType,
                x.EntityType,
                x.EntityId,
                x.DaysBeforeEvent,
                x.TargetDate
            })
            .IsUnique()
            .HasFilter("[IsDeleted] = 0");
    }
}
