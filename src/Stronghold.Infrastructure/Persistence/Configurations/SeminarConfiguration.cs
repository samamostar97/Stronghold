using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Stronghold.Domain.Entities;

namespace Stronghold.Infrastructure.Persistence.Configurations;

public class SeminarConfiguration : IEntityTypeConfiguration<Seminar>
{
    public void Configure(EntityTypeBuilder<Seminar> builder)
    {
        builder.HasKey(s => s.Id);
        builder.Property(s => s.Name).IsRequired().HasMaxLength(200);
        builder.Property(s => s.Description).HasMaxLength(1000);
        builder.Property(s => s.Lecturer).IsRequired().HasMaxLength(200);
        builder.Property(s => s.DurationMinutes).HasDefaultValue(120);
        builder.Property(s => s.MaxCapacity).IsRequired();

        builder.HasMany(s => s.Registrations)
            .WithOne(r => r.Seminar)
            .HasForeignKey(r => r.SeminarId);
    }
}
