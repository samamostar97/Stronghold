using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Configurations;

public class UserConfiguration : BaseEntityConfiguration<User>
{
    public override void Configure(EntityTypeBuilder<User> builder)
    {
        base.Configure(builder);

        builder.Property(u => u.FirstName).HasMaxLength(100).IsRequired();
        builder.Property(u => u.LastName).HasMaxLength(100).IsRequired();
        builder.Property(u => u.Username).HasMaxLength(50).IsRequired();
        builder.Property(u => u.Email).HasMaxLength(255).IsRequired();
        builder.Property(u => u.PhoneNumber).HasMaxLength(20).IsRequired();
        builder.Property(u => u.PasswordHash).IsRequired();
        builder.Property(u => u.ProfileImageUrl).HasMaxLength(500);

        builder.HasIndex(u => u.PhoneNumber).IsUnique().HasFilter("[IsDeleted]= 0");
        builder.HasIndex(u => u.Username).IsUnique().HasFilter("[IsDeleted] = 0");
        builder.HasIndex(u => u.Email).IsUnique().HasFilter("[IsDeleted] = 0");
    }
}
