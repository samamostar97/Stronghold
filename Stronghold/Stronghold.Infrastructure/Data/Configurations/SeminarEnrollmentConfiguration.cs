using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Data.Configurations
{
    public class SeminarEnrollmentConfiguration : IEntityTypeConfiguration<SeminarEnrollment>
    {
        public void Configure(EntityTypeBuilder<SeminarEnrollment> builder)
        {
            builder.HasKey(se => se.Id);

            builder.Property(se => se.UserId)
                .IsRequired();

            builder.Property(se => se.SeminarId)
                .IsRequired();

            builder.Property(se => se.EnrolledAt)
                .IsRequired();

            builder.Property(se => se.IsAttended)
                .IsRequired();

            builder.Property(se => se.IsCancelled)
                .IsRequired();

            builder.HasOne(se => se.User)
                .WithMany(u => u.SeminarEnrollments)
                .HasForeignKey(se => se.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.HasOne(se => se.Seminar)
                .WithMany(s => s.SeminarEnrollments)
                .HasForeignKey(se => se.SeminarId)
                .OnDelete(DeleteBehavior.Cascade);

            // Composite index to prevent duplicate enrollments
            builder.HasIndex(se => new { se.UserId, se.SeminarId })
                .IsUnique();
        }
    }
}
