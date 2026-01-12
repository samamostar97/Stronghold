using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Configurations;

public class MembershipPaymentConfiguration : BaseEntityConfiguration<MembershipPayment>
{
    public override void Configure(EntityTypeBuilder<MembershipPayment> builder)
    {
        base.Configure(builder);

        builder.Property(m => m.Amount).HasPrecision(18, 2).IsRequired();
        builder.Property(m => m.PaymentDate).IsRequired();

        builder.HasOne(m => m.User)
            .WithMany(u => u.MembershipPayments)
            .HasForeignKey(m => m.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(m => m.MembershipPackage)
            .WithMany()
            .HasForeignKey(m => m.MembershipPackageId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
