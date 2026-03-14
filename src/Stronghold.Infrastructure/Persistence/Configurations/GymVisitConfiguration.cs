using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Stronghold.Domain.Entities;

namespace Stronghold.Infrastructure.Persistence.Configurations;

public class GymVisitConfiguration : IEntityTypeConfiguration<GymVisit>
{
    public void Configure(EntityTypeBuilder<GymVisit> builder)
    {
        builder.HasKey(v => v.Id);

        builder.Property(v => v.UserFullName).IsRequired().HasMaxLength(200);
        builder.Property(v => v.Username).IsRequired().HasMaxLength(100);
        builder.Property(v => v.CheckInAt).IsRequired();

        builder.HasOne(v => v.User)
            .WithMany()
            .HasForeignKey(v => v.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasIndex(v => v.UserId);
        builder.HasIndex(v => new { v.UserId, v.CheckOutAt });
    }
}
