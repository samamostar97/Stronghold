using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Data.Configurations
{
    public class MembershipConfiguration : IEntityTypeConfiguration<Membership>
    {
        public void Configure(EntityTypeBuilder<Membership> builder)
        {
            builder.HasKey(m => m.Id);

            builder.Property(m => m.UserId)
                .IsRequired();

            builder.Property(m => m.MembershipPackageId)
                .IsRequired();

            builder.Property(m => m.EndDate)
                .IsRequired();

            builder.Property(m => m.IsPaid)
                .IsRequired();

            builder.Property(m => m.IsActive)
                .IsRequired();

            builder.Property(m => m.CreatedAt)
                .IsRequired();

            builder.HasOne(m => m.MembershipPackage)
                .WithMany(mp => mp.Memberships)
                .HasForeignKey(m => m.MembershipPackageId)
                .OnDelete(DeleteBehavior.Restrict);
        }
    }
}
