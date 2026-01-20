using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Configurations;

public class GymVisitConfiguration : BaseEntityConfiguration<GymVisit>
{
    public override void Configure(EntityTypeBuilder<GymVisit> builder)
    {
        base.Configure(builder);

        builder.Property(g => g.CheckInTime).IsRequired();
        builder.Ignore(g => g.Duration);

        builder.HasOne(g => g.User)
            .WithMany(u => u.GymVisits)
            .HasForeignKey(g => g.UserId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
