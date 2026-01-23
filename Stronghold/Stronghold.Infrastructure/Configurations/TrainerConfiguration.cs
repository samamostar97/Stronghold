using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Configurations;

public class TrainerConfiguration : BaseEntityConfiguration<Trainer>
{
    public override void Configure(EntityTypeBuilder<Trainer> builder)
    {
        base.Configure(builder);

        builder.Property(t => t.FirstName).HasMaxLength(100).IsRequired();
        builder.Property(t => t.LastName).HasMaxLength(100).IsRequired();
        builder.Property(t => t.Email).HasMaxLength(255).IsRequired();
        builder.Property(t => t.PhoneNumber).HasMaxLength(20).IsRequired();

        builder.HasIndex(t => t.Email)
               .IsUnique()
               .HasFilter("[IsDeleted] = 0"); 
    }
}
