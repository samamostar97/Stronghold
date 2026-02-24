using Stronghold.Core.Entities;
using Stronghold.Core.Enums;
using Stronghold.Infrastructure.Services;
using Stronghold.Infrastructure.Tests.TestHelpers;

namespace Stronghold.Infrastructure.Tests;

public class ReportServiceTests
{
    [Fact]
    public async Task GetInventorySummaryAsync_ShouldIgnoreSoftDeletedOrdersWhenCalculatingSales()
    {
        await using var context = TestDbContextFactory.Create();
        var reportService = new ReportService(context);

        var category = new SupplementCategory { Name = "Protein" };
        var supplier = new Supplier { Name = "SuppCo" };
        var supplement = new Supplement
        {
            Name = "Whey Gold",
            Price = 59.99m,
            SupplementCategory = category,
            Supplier = supplier
        };
        var user = new User
        {
            FirstName = "Marko",
            LastName = "Test",
            Username = "marko",
            Email = "marko@example.com",
            PhoneNumber = "061000000",
            Role = Role.GymMember,
            Gender = Gender.Male,
            PasswordHash = "hash"
        };

        context.SupplementCategories.Add(category);
        context.Suppliers.Add(supplier);
        context.Supplements.Add(supplement);
        context.Users.Add(user);
        await context.SaveChangesAsync();

        var deletedOrder = new Order
        {
            UserId = user.Id,
            PurchaseDate = DateTime.UtcNow.AddDays(-1),
            TotalAmount = 119.98m,
            Status = OrderStatus.Delivered,
            IsDeleted = true
        };

        context.Orders.Add(deletedOrder);
        await context.SaveChangesAsync();

        context.OrderItems.Add(new OrderItem
        {
            OrderId = deletedOrder.Id,
            SupplementId = supplement.Id,
            Quantity = 5,
            UnitPrice = 23.996m
        });
        await context.SaveChangesAsync();

        var summary = await reportService.GetInventorySummaryAsync(30);

        Assert.Equal(1, summary.TotalProducts);
        Assert.Equal(1, summary.SlowMovingCount);
    }

    [Fact]
    public async Task GetActivityFeedAsync_ShouldExcludeSoftDeletedEntities()
    {
        await using var context = TestDbContextFactory.Create();
        var reportService = new ReportService(context);

        var activeUser = new User
        {
            FirstName = "John",
            LastName = "Doe",
            Username = "john",
            Email = "john@example.com",
            PhoneNumber = "061111111",
            Role = Role.GymMember,
            Gender = Gender.Male,
            PasswordHash = "hash"
        };
        var deletedUser = new User
        {
            FirstName = "Zara",
            LastName = "Deleted",
            Username = "zara",
            Email = "zara@example.com",
            PhoneNumber = "062222222",
            Role = Role.GymMember,
            Gender = Gender.Female,
            PasswordHash = "hash",
            IsDeleted = true
        };
        var activePackage = new MembershipPackage
        {
            PackageName = "Monthly",
            PackagePrice = 49.99m,
            Description = "Monthly package"
        };

        context.Users.AddRange(activeUser, deletedUser);
        context.MembershipPackages.Add(activePackage);
        await context.SaveChangesAsync();

        context.Orders.AddRange(
            new Order
            {
                UserId = activeUser.Id,
                PurchaseDate = DateTime.UtcNow.AddMinutes(-20),
                TotalAmount = 50m,
                Status = OrderStatus.Processing
            },
            new Order
            {
                UserId = deletedUser.Id,
                PurchaseDate = DateTime.UtcNow.AddMinutes(-10),
                TotalAmount = 75m,
                Status = OrderStatus.Delivered,
                IsDeleted = true
            });

        context.Memberships.AddRange(
            new Membership
            {
                UserId = activeUser.Id,
                MembershipPackageId = activePackage.Id,
                StartDate = DateTime.UtcNow.AddDays(-5),
                EndDate = DateTime.UtcNow.AddDays(25)
            },
            new Membership
            {
                UserId = deletedUser.Id,
                MembershipPackageId = activePackage.Id,
                StartDate = DateTime.UtcNow.AddDays(-2),
                EndDate = DateTime.UtcNow.AddDays(28),
                IsDeleted = true
            });

        await context.SaveChangesAsync();

        var feed = await reportService.GetActivityFeedAsync(20);

        Assert.Contains(feed, x => x.UserName == "John Doe");
        Assert.DoesNotContain(feed, x => x.UserName == "Zara Deleted");
    }
}
