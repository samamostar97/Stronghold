using Microsoft.EntityFrameworkCore;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Data;

public class StrongholdDbContext : DbContext
{
    public StrongholdDbContext(DbContextOptions<StrongholdDbContext> options) : base(options)
    {
    }

    public DbSet<User> Users => Set<User>();
    public DbSet<GymVisit> GymVisits => Set<GymVisit>();
    public DbSet<MembershipPackage> MembershipPackages => Set<MembershipPackage>();
    public DbSet<Membership> Memberships => Set<Membership>();
    public DbSet<MembershipPaymentHistory> MembershipPaymentHistory => Set<MembershipPaymentHistory>();
    public DbSet<SupplementCategory> SupplementCategories => Set<SupplementCategory>();
    public DbSet<Supplier> Suppliers => Set<Supplier>();
    public DbSet<Supplement> Supplements => Set<Supplement>();
    public DbSet<Order> Orders => Set<Order>();
    public DbSet<OrderItem> OrderItems => Set<OrderItem>();
    public DbSet<Trainer> Trainers => Set<Trainer>();
    public DbSet<Nutritionist> Nutritionists => Set<Nutritionist>();
    public DbSet<Appointment> Appointments => Set<Appointment>();
    public DbSet<Seminar> Seminars => Set<Seminar>();
    public DbSet<SeminarAttendee> SeminarAttendees => Set<SeminarAttendee>();
    public DbSet<Review> Reviews => Set<Review>();
    public DbSet<FAQ> FAQs => Set<FAQ>();
    public DbSet<PasswordResetToken> PasswordResetTokens => Set<PasswordResetToken>();
    public DbSet<Notification> Notifications => Set<Notification>();
    public DbSet<Address> Addresses => Set<Address>();
    public DbSet<ReminderDispatchLog> ReminderDispatchLogs => Set<ReminderDispatchLog>();
    public DbSet<AdminActivityLog> AdminActivityLogs => Set<AdminActivityLog>();
    public DbSet<StockLog> StockLogs => Set<StockLog>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(StrongholdDbContext).Assembly);
    }

    public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        foreach (var entry in ChangeTracker.Entries<BaseEntity>())
        {
            switch (entry.State)
            {
                case EntityState.Added:
                    entry.Entity.CreatedAt = DateTime.UtcNow;
                    break;
                case EntityState.Modified:
                    entry.Entity.UpdatedAt = DateTime.UtcNow;
                    break;
            }
        }

        return base.SaveChangesAsync(cancellationToken);
    }
}
