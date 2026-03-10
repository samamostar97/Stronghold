using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Stronghold.Domain.Entities;

namespace Stronghold.Infrastructure.Persistence.Configurations;

public class UserMembershipConfiguration : IEntityTypeConfiguration<UserMembership>
{
    public void Configure(EntityTypeBuilder<UserMembership> builder)
    {
        builder.HasKey(m => m.Id);

        builder.Property(m => m.StartDate).IsRequired();
        builder.Property(m => m.EndDate).IsRequired();
        builder.Property(m => m.IsActive).IsRequired();

        builder.HasOne(m => m.User)
            .WithMany()
            .HasForeignKey(m => m.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(m => m.MembershipPackage)
            .WithMany()
            .HasForeignKey(m => m.MembershipPackageId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasIndex(m => m.UserId);
        builder.HasIndex(m => new { m.UserId, m.IsActive });
    }
}
