using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Configurations;

public class AppointmentConfiguration : BaseEntityConfiguration<Appointment>
{
    public override void Configure(EntityTypeBuilder<Appointment> builder)
    {
        base.Configure(builder);

        builder.Property(a => a.AppointmentDate).IsRequired();

        builder.HasOne(a => a.User)
            .WithMany(u => u.Appointments)
            .HasForeignKey(a => a.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(a => a.Trainer)
            .WithMany(t => t.Appointments)
            .HasForeignKey(a => a.TrainerId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(a => a.Nutritionist)
            .WithMany(n => n.Appointments)
            .HasForeignKey(a => a.NutritionistId)
            .OnDelete(DeleteBehavior.Restrict);

        // Prevent double-booking trainers at the same time
        builder.HasIndex(a => new { a.TrainerId, a.AppointmentDate })
            .IsUnique()
            .HasFilter("[TrainerId] IS NOT NULL AND [IsDeleted] = 0");

        // Prevent double-booking nutritionists at the same time
        builder.HasIndex(a => new { a.NutritionistId, a.AppointmentDate })
            .IsUnique()
            .HasFilter("[NutritionistId] IS NOT NULL AND [IsDeleted] = 0");
    }
}
