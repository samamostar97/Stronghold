using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Stronghold.Domain.Entities;

namespace Stronghold.Infrastructure.Persistence.Configurations;

public class SupplierConfiguration : IEntityTypeConfiguration<Supplier>
{
    public void Configure(EntityTypeBuilder<Supplier> builder)
    {
        builder.HasKey(s => s.Id);

        builder.Property(s => s.Name).IsRequired().HasMaxLength(200);
        builder.Property(s => s.Email).IsRequired().HasMaxLength(200);
        builder.Property(s => s.Phone).HasMaxLength(20);
        builder.Property(s => s.Website).HasMaxLength(500);

        builder.HasIndex(s => s.Email).IsUnique().HasFilter("IsDeleted = 0");
    }
}
