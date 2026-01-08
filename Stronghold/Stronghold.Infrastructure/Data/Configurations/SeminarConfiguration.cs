using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Data.Configurations
{
    public class SeminarConfiguration : IEntityTypeConfiguration<Seminar>
    {
        public void Configure(EntityTypeBuilder<Seminar> builder)
        {
            builder.HasKey(s => s.Id);

            builder.Property(s => s.Theme)
                .IsRequired()
                .HasMaxLength(200);

            builder.Property(s => s.LecturerId)
                .IsRequired();

            builder.Property(s => s.ScheduledDate)
                .IsRequired();

            builder.Property(s => s.DurationMinutes)
                .IsRequired();

            builder.Property(s => s.Description)
                .HasMaxLength(1000);

            builder.Property(s => s.IsCancelled)
                .IsRequired();

            builder.Property(s => s.CreatedAt)
                .IsRequired();
        }
    }
}
