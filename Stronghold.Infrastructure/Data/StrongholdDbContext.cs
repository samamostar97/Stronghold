using Microsoft.EntityFrameworkCore;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;

namespace Stronghold.Infrastructure.Data;

public class StrongholdDbContext : DbContext
{
    public StrongholdDbContext(DbContextOptions<StrongholdDbContext> options) : base(options)
    {
    }

    public DbSet<User> Users => Set<User>();
    public DbSet<City> Cities => Set<City>();
    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
    public DbSet<PasswordResetToken> PasswordResetTokens => Set<PasswordResetToken>();
    public DbSet<MembershipPackage> MembershipPackages => Set<MembershipPackage>();
    public DbSet<Membership> Memberships => Set<Membership>();
    public DbSet<Payment> Payments => Set<Payment>();
    public DbSet<GymVisit> GymVisits => Set<GymVisit>();
    public DbSet<SupplementCategory> SupplementCategories => Set<SupplementCategory>();
    public DbSet<Supplier> Suppliers => Set<Supplier>();
    public DbSet<Supplement> Supplements => Set<Supplement>();
    public DbSet<Order> Orders => Set<Order>();
    public DbSet<OrderItem> OrderItems => Set<OrderItem>();
    public DbSet<StaffMember> StaffMembers => Set<StaffMember>();
    public DbSet<Appointment> Appointments => Set<Appointment>();
    public DbSet<Seminar> Seminars => Set<Seminar>();
    public DbSet<SeminarRegistration> SeminarRegistrations => Set<SeminarRegistration>();
    public DbSet<Review> Reviews => Set<Review>();
    public DbSet<Faq> Faqs => Set<Faq>();
    public DbSet<Notification> Notifications => Set<Notification>();
    public DbSet<CartItem> CartItems => Set<CartItem>();
    public DbSet<ActivityLog> ActivityLogs => Set<ActivityLog>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<User>(entity =>
        {
            entity.Property(u => u.FirstName).HasMaxLength(50).IsRequired();
            entity.Property(u => u.LastName).HasMaxLength(50).IsRequired();
            entity.Property(u => u.Username).HasMaxLength(50).IsRequired();
            entity.Property(u => u.Email).HasMaxLength(100).IsRequired();
            entity.Property(u => u.Phone).HasMaxLength(30).IsRequired();
            entity.Property(u => u.PasswordHash).HasMaxLength(200).IsRequired();
            entity.Property(u => u.PasswordSalt).HasMaxLength(200).IsRequired();
            entity.Property(u => u.StreetAddress).HasMaxLength(100);
            entity.HasIndex(u => u.Username).IsUnique();
            entity.HasIndex(u => u.Email).IsUnique();
            entity.HasOne(u => u.City)
                .WithMany(c => c.Users)
                .HasForeignKey(u => u.CityId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<City>(entity =>
        {
            entity.Property(c => c.Name).HasMaxLength(80).IsRequired();
            entity.HasIndex(c => c.Name).IsUnique();
        });

        modelBuilder.Entity<RefreshToken>(entity =>
        {
            entity.Property(t => t.Token).HasMaxLength(200).IsRequired();
            entity.HasIndex(t => t.Token).IsUnique();
            entity.HasOne(t => t.User)
                .WithMany(u => u.RefreshTokens)
                .HasForeignKey(t => t.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<PasswordResetToken>(entity =>
        {
            entity.Property(t => t.CodeHash).HasMaxLength(200).IsRequired();
            entity.Property(t => t.CodeSalt).HasMaxLength(200).IsRequired();
            entity.HasOne(t => t.User)
                .WithMany()
                .HasForeignKey(t => t.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<MembershipPackage>(entity =>
        {
            entity.Property(p => p.Name).HasMaxLength(80).IsRequired();
            entity.Property(p => p.Description).HasMaxLength(500).IsRequired();
            entity.Property(p => p.Price).HasPrecision(18, 2);
        });

        modelBuilder.Entity<Membership>(entity =>
        {
            entity.Property(m => m.RevocationReason).HasMaxLength(300);
            entity.HasOne(m => m.User)
                .WithMany(u => u.Memberships)
                .HasForeignKey(m => m.UserId)
                .OnDelete(DeleteBehavior.Restrict);
            entity.HasOne(m => m.Package)
                .WithMany(p => p.Memberships)
                .HasForeignKey(m => m.PackageId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<Payment>(entity =>
        {
            entity.Property(p => p.Amount).HasPrecision(18, 2);
            entity.HasOne(p => p.Membership)
                .WithMany(m => m.Payments)
                .HasForeignKey(p => p.MembershipId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<GymVisit>(entity =>
        {
            entity.HasOne(v => v.User)
                .WithMany(u => u.GymVisits)
                .HasForeignKey(v => v.UserId)
                .OnDelete(DeleteBehavior.Cascade);
            // Korisnik moze imati najvise jednu otvorenu posjetu - sprjecava dupli check-in na nivou baze.
            entity.HasIndex(v => v.UserId)
                .IsUnique()
                .HasFilter("[CheckOutAt] IS NULL");
        });

        modelBuilder.Entity<SupplementCategory>(entity =>
        {
            entity.Property(c => c.Name).HasMaxLength(80).IsRequired();
            entity.Property(c => c.Description).HasMaxLength(500).IsRequired();
            entity.HasIndex(c => c.Name).IsUnique();
        });

        modelBuilder.Entity<Supplier>(entity =>
        {
            entity.Property(s => s.Name).HasMaxLength(100).IsRequired();
            entity.Property(s => s.ContactEmail).HasMaxLength(100).IsRequired();
            entity.Property(s => s.ContactPhone).HasMaxLength(30).IsRequired();
            entity.HasIndex(s => s.Name).IsUnique();
        });

        modelBuilder.Entity<Supplement>(entity =>
        {
            entity.Property(s => s.Name).HasMaxLength(120).IsRequired();
            entity.Property(s => s.Description).HasMaxLength(1000).IsRequired();
            entity.Property(s => s.Price).HasPrecision(18, 2);
            entity.HasOne(s => s.Category)
                .WithMany(c => c.Supplements)
                .HasForeignKey(s => s.CategoryId)
                .OnDelete(DeleteBehavior.Restrict);
            entity.HasOne(s => s.Supplier)
                .WithMany(s => s.Supplements)
                .HasForeignKey(s => s.SupplierId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<Order>(entity =>
        {
            entity.Property(o => o.TotalAmount).HasPrecision(18, 2);
            entity.Property(o => o.StripePaymentIntentId).HasMaxLength(100).IsRequired();
            entity.Property(o => o.DeliveryStreet).HasMaxLength(100).IsRequired();
            entity.Property(o => o.CancellationReason).HasMaxLength(300);
            entity.HasIndex(o => o.StripePaymentIntentId).IsUnique();
            entity.HasOne(o => o.User)
                .WithMany(u => u.Orders)
                .HasForeignKey(o => o.UserId)
                .OnDelete(DeleteBehavior.Restrict);
            entity.HasOne(o => o.DeliveryCity)
                .WithMany(c => c.Orders)
                .HasForeignKey(o => o.DeliveryCityId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<OrderItem>(entity =>
        {
            entity.Property(i => i.UnitPrice).HasPrecision(18, 2);
            entity.HasOne(i => i.Order)
                .WithMany(o => o.Items)
                .HasForeignKey(i => i.OrderId)
                .OnDelete(DeleteBehavior.Cascade);
            entity.HasOne(i => i.Supplement)
                .WithMany(s => s.OrderItems)
                .HasForeignKey(i => i.SupplementId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<StaffMember>(entity =>
        {
            entity.Property(s => s.FirstName).HasMaxLength(50).IsRequired();
            entity.Property(s => s.LastName).HasMaxLength(50).IsRequired();
            entity.Property(s => s.Biography).HasMaxLength(2000).IsRequired();
            entity.Property(s => s.Email).HasMaxLength(100).IsRequired();
            entity.Property(s => s.Phone).HasMaxLength(30).IsRequired();
        });

        modelBuilder.Entity<Appointment>(entity =>
        {
            entity.Property(a => a.CancellationReason).HasMaxLength(300);
            entity.HasOne(a => a.User)
                .WithMany(u => u.Appointments)
                .HasForeignKey(a => a.UserId)
                .OnDelete(DeleteBehavior.Restrict);
            entity.HasOne(a => a.StaffMember)
                .WithMany(s => s.Appointments)
                .HasForeignKey(a => a.StaffMemberId)
                .OnDelete(DeleteBehavior.Restrict);
            // Slot je zauzet dok termin nije otkazan - sprjecava dvostruki booking na nivou baze.
            entity.HasIndex(a => new { a.StaffMemberId, a.Date, a.StartHour })
                .IsUnique()
                .HasFilter($"[Status] <> {(int)AppointmentStatus.Cancelled}");
        });

        modelBuilder.Entity<Seminar>(entity =>
        {
            entity.Property(s => s.Topic).HasMaxLength(150).IsRequired();
            entity.Property(s => s.Speaker).HasMaxLength(100).IsRequired();
            entity.Property(s => s.CancellationReason).HasMaxLength(300);
        });

        modelBuilder.Entity<SeminarRegistration>(entity =>
        {
            entity.HasIndex(r => new { r.SeminarId, r.UserId }).IsUnique();
            entity.HasOne(r => r.Seminar)
                .WithMany(s => s.Registrations)
                .HasForeignKey(r => r.SeminarId)
                .OnDelete(DeleteBehavior.Restrict);
            entity.HasOne(r => r.User)
                .WithMany(u => u.SeminarRegistrations)
                .HasForeignKey(r => r.UserId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<Review>(entity =>
        {
            entity.Property(r => r.Comment).HasMaxLength(1000);
            entity.HasIndex(r => new { r.UserId, r.SupplementId }).IsUnique();
            entity.HasOne(r => r.User)
                .WithMany(u => u.Reviews)
                .HasForeignKey(r => r.UserId)
                .OnDelete(DeleteBehavior.Restrict);
            entity.HasOne(r => r.Supplement)
                .WithMany(s => s.Reviews)
                .HasForeignKey(r => r.SupplementId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<Faq>(entity =>
        {
            entity.Property(f => f.Question).HasMaxLength(300).IsRequired();
            entity.Property(f => f.Answer).HasMaxLength(2000).IsRequired();
        });

        modelBuilder.Entity<Notification>(entity =>
        {
            entity.Property(n => n.Title).HasMaxLength(150).IsRequired();
            entity.Property(n => n.Message).HasMaxLength(1000).IsRequired();
            entity.HasOne(n => n.User)
                .WithMany(u => u.Notifications)
                .HasForeignKey(n => n.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<CartItem>(entity =>
        {
            // jedna stavka po suplementu - ponovno dodavanje povecava kolicinu
            entity.HasIndex(ci => new { ci.UserId, ci.SupplementId }).IsUnique();
            entity.HasOne(ci => ci.User)
                .WithMany(u => u.CartItems)
                .HasForeignKey(ci => ci.UserId)
                .OnDelete(DeleteBehavior.Cascade);
            // korpa je efemerna - ne smije blokirati brisanje suplementa
            entity.HasOne(ci => ci.Supplement)
                .WithMany()
                .HasForeignKey(ci => ci.SupplementId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<ActivityLog>(entity =>
        {
            entity.Property(l => l.EntityName).HasMaxLength(80).IsRequired();
            entity.Property(l => l.EntityDisplay).HasMaxLength(200);
            entity.HasOne(l => l.PerformedBy)
                .WithMany()
                .HasForeignKey(l => l.PerformedByUserId)
                .OnDelete(DeleteBehavior.Restrict);
        });
    }
}
