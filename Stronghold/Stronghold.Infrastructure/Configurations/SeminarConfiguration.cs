using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Configurations;

public class SeminarConfiguration : BaseEntityConfiguration<Seminar>
{
    public override void Configure(EntityTypeBuilder<Seminar> builder)
    {
        base.Configure(builder);

        builder.Property(s => s.Topic).HasMaxLength(200).IsRequired();
        builder.Property(s => s.SpeakerName).HasMaxLength(100).IsRequired();
        builder.Property(s => s.EventDate).IsRequired();
        builder.Property(s => s.MaxCapacity).IsRequired();
    }
}
