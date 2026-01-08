using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Data.Configurations
{
    public class MembershipPackageConfiguration : IEntityTypeConfiguration<MembershipPackage>
    {
        public void Configure(EntityTypeBuilder<MembershipPackage> builder)
        {
            builder.HasKey(mp => mp.Id);

            builder.Property(mp => mp.Name)
                .IsRequired()
                .HasMaxLength(100);

            builder.Property(mp => mp.Description)
                .HasMaxLength(500);

            builder.Property(mp => mp.Price)
                .IsRequired()
                .HasPrecision(18, 2);

            builder.Property(mp => mp.DurationDays)
                .IsRequired();

            builder.Property(mp => mp.CreatedAt)
                .IsRequired();
        }
    }
}
