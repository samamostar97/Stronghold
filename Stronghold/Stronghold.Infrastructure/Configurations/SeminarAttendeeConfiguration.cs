using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Configurations;

public class SeminarAttendeeConfiguration : BaseEntityConfiguration<SeminarAttendee>
{
    public override void Configure(EntityTypeBuilder<SeminarAttendee> builder)
    {
        base.Configure(builder);

        builder.Property(sa => sa.RegisteredAt).IsRequired();

        builder.HasOne(sa => sa.User)
            .WithMany(u => u.SeminarAttendees)
            .HasForeignKey(sa => sa.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(sa => sa.Seminar)
            .WithMany(s => s.SeminarAttendees)
            .HasForeignKey(sa => sa.SeminarId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasIndex(sa => new { sa.UserId, sa.SeminarId }).IsUnique().HasFilter("[IsDeleted] = 0");
    }
}
