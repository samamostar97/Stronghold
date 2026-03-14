using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Stronghold.Domain.Entities;

namespace Stronghold.Infrastructure.Persistence.Configurations;

public class StaffConfiguration : IEntityTypeConfiguration<Staff>
{
    public void Configure(EntityTypeBuilder<Staff> builder)
    {
        builder.HasKey(s => s.Id);

        builder.Property(s => s.FirstName).IsRequired().HasMaxLength(100);
        builder.Property(s => s.LastName).IsRequired().HasMaxLength(100);
        builder.Property(s => s.Email).IsRequired().HasMaxLength(200);
        builder.Property(s => s.Phone).HasMaxLength(20);
        builder.Property(s => s.Bio).HasMaxLength(1000);
        builder.Property(s => s.ProfileImageUrl).HasMaxLength(500);
        builder.Property(s => s.StaffType).IsRequired().HasConversion<string>().HasMaxLength(20);
        builder.Property(s => s.IsActive).IsRequired().HasDefaultValue(true);

        builder.HasIndex(s => s.Email).IsUnique().HasFilter("IsDeleted = 0");
        builder.HasIndex(s => s.Phone).IsUnique().HasFilter("IsDeleted = 0 AND Phone IS NOT NULL");
    }
}
