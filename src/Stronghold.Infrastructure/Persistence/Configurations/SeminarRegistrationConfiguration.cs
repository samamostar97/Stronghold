using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Stronghold.Domain.Entities;

namespace Stronghold.Infrastructure.Persistence.Configurations;

public class SeminarRegistrationConfiguration : IEntityTypeConfiguration<SeminarRegistration>
{
    public void Configure(EntityTypeBuilder<SeminarRegistration> builder)
    {
        builder.HasKey(r => r.Id);

        builder.HasOne(r => r.User)
            .WithMany()
            .HasForeignKey(r => r.UserId);

        builder.HasIndex(r => new { r.SeminarId, r.UserId })
            .IsUnique()
            .HasFilter("[IsDeleted] = 0");
    }
}
