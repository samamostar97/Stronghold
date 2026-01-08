using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Data.Configurations
{
    public class AppointmentConfiguration : IEntityTypeConfiguration<Appointment>
    {
        public void Configure(EntityTypeBuilder<Appointment> builder)
        {
            builder.HasKey(a => a.Id);

            builder.Property(a => a.MemberId)
                .IsRequired();

            builder.Property(a => a.ProfessionalId)
                .IsRequired();

            builder.Property(a => a.AppointmentType)
                .IsRequired();

            builder.Property(a => a.AppointmentDate)
                .IsRequired();

            builder.Property(a => a.DurationMinutes)
                .IsRequired();

            builder.Property(a => a.Notes)
                .HasMaxLength(1000);

            builder.Property(a => a.IsCompleted)
                .IsRequired();

            builder.Property(a => a.IsCancelled)
                .IsRequired();

            builder.Property(a => a.CreatedAt)
                .IsRequired();
        }
    }
}
