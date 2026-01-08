using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Data.Configurations
{
    public class ProgressConfiguration : IEntityTypeConfiguration<Progress>
    {
        public void Configure(EntityTypeBuilder<Progress> builder)
        {
            builder.HasKey(p => p.Id);

            builder.Property(p => p.UserId)
                .IsRequired();

            builder.Property(p => p.Weight)
                .IsRequired()
                .HasPrecision(5, 2);

            builder.Property(p => p.BodyFatPercentage)
                .HasPrecision(5, 2);

            builder.Property(p => p.WaistMeasurement)
                .HasPrecision(5, 2);

            builder.Property(p => p.ArmMeasurement)
                .HasPrecision(5, 2);

            builder.Property(p => p.Notes)
                .HasMaxLength(500);

            builder.Property(p => p.MeasurementDate)
                .IsRequired();

            builder.Property(p => p.CreatedAt)
                .IsRequired();
        }
    }
}
