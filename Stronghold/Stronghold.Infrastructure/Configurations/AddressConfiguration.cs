using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Configurations;

public class AddressConfiguration : BaseEntityConfiguration<Address>
{
    public override void Configure(EntityTypeBuilder<Address> builder)
    {
        base.Configure(builder);

        builder.Property(a => a.Street).IsRequired().HasMaxLength(200);
        builder.Property(a => a.City).IsRequired().HasMaxLength(100);
        builder.Property(a => a.PostalCode).IsRequired().HasMaxLength(20);
        builder.Property(a => a.Country).IsRequired().HasMaxLength(100)
            .HasDefaultValue("Bosna i Hercegovina");

        builder.HasOne(a => a.User)
            .WithOne(u => u.Address)
            .HasForeignKey<Address>(a => a.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasIndex(a => a.UserId).IsUnique();
    }
}
