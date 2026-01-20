using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Configurations;

public class NutritionistConfiguration : BaseEntityConfiguration<Nutritionist>
{
    public override void Configure(EntityTypeBuilder<Nutritionist> builder)
    {
        base.Configure(builder);

        builder.Property(n => n.FirstName).HasMaxLength(100).IsRequired();
        builder.Property(n => n.LastName).HasMaxLength(100).IsRequired();
        builder.Property(n => n.Email).HasMaxLength(255).IsRequired();
        builder.Property(n => n.PhoneNumber).HasMaxLength(20).IsRequired();

        builder.HasIndex(n => n.Email).IsUnique();
    }
}
