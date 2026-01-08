using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Data.Configurations
{
    public class ProductCategoryConfiguration : IEntityTypeConfiguration<ProductCategory>
    {
        public void Configure(EntityTypeBuilder<ProductCategory> builder)
        {
            builder.HasKey(pc => pc.Id);

            builder.Property(pc => pc.Name)
                .IsRequired()
                .HasMaxLength(100);

            builder.Property(pc => pc.Description)
                .HasMaxLength(500);

            builder.Property(pc => pc.CreatedAt)
                .IsRequired();

            builder.HasIndex(pc => pc.Name)
                .IsUnique();
        }
    }
}
