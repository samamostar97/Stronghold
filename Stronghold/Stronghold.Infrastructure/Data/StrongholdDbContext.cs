using Microsoft.EntityFrameworkCore;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Data
{
    public class StrongholdDbContext : DbContext
    {
        public StrongholdDbContext(DbContextOptions<StrongholdDbContext> options) : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<Membership> Memberships { get; set; }
        public DbSet<MembershipPackage> MembershipPackages { get; set; }
        public DbSet<Product> Products { get; set; }
        public DbSet<ProductCategory> ProductCategories { get; set; }
        public DbSet<Supplier> Suppliers { get; set; }
        public DbSet<Order> Orders { get; set; }
        public DbSet<OrderItem> OrderItems { get; set; }
        public DbSet<Review> Reviews { get; set; }
        public DbSet<Appointment> Appointments { get; set; }
        public DbSet<Seminar> Seminars { get; set; }
        public DbSet<SeminarEnrollment> SeminarEnrollments { get; set; }
        public DbSet<Progress> ProgressRecords { get; set; }
        public DbSet<FAQ> FAQs { get; set; }
        public DbSet<RefreshToken> RefreshTokens { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.ApplyConfigurationsFromAssembly(typeof(StrongholdDbContext).Assembly);
        }
    }
}
