using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Stronghold.Domain.Entities;

namespace Stronghold.Infrastructure.Persistence.Configurations;

public class LevelConfiguration : IEntityTypeConfiguration<Level>
{
    public void Configure(EntityTypeBuilder<Level> builder)
    {
        builder.HasKey(l => l.Id);

        builder.Property(l => l.Name).IsRequired().HasMaxLength(100);
        builder.Property(l => l.MinXP).IsRequired();
        builder.Property(l => l.MaxXP).IsRequired();
        builder.Property(l => l.BadgeImageUrl).HasMaxLength(500);
    }
}
