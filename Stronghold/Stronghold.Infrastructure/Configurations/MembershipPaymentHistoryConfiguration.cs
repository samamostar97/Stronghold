using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Configurations;

public class MembershipPaymentHistoryConfiguration : BaseEntityConfiguration<MembershipPaymentHistory>
{
    public override void Configure(EntityTypeBuilder<MembershipPaymentHistory> builder)
    {
        base.Configure(builder);

        builder.Property(m => m.AmountPaid).HasPrecision(18, 2).IsRequired();
        builder.Property(m => m.PaymentDate).IsRequired();
        builder.Property(m => m.StartDate).IsRequired();
        builder.Property(m => m.EndDate).IsRequired();

        builder.HasOne(m => m.User)
            .WithMany(u => u.MembershipPaymentHistory)
            .HasForeignKey(m => m.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(m => m.MembershipPackage)
            .WithMany(mp => mp.PaymentHistory)
            .HasForeignKey(m => m.MembershipPackageId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
