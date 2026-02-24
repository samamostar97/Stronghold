using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Features.Orders.DTOs;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;
using Stronghold.Infrastructure.Repositories;
using Stronghold.Infrastructure.Tests.TestHelpers;

namespace Stronghold.Infrastructure.Tests;

public class OrderRepositoryTests
{
    [Fact]
    public async Task GetPagedAsync_ShouldExcludeSoftDeletedOrders()
    {
        await using var context = TestDbContextFactory.Create();
        var seed = await SeedBaseAsync(context);
        var repository = new OrderRepository(context);

        var visibleOrder = new Order
        {
            UserId = seed.UserJohn.Id,
            TotalAmount = 50m,
            PurchaseDate = DateTime.UtcNow.AddDays(-1),
            Status = OrderStatus.Processing,
            OrderItems =
            [
                new OrderItem { SupplementId = seed.SupplementA.Id, Quantity = 1, UnitPrice = 50m }
            ]
        };
        var deletedOrder = new Order
        {
            UserId = seed.UserAna.Id,
            TotalAmount = 70m,
            PurchaseDate = DateTime.UtcNow.AddDays(-2),
            Status = OrderStatus.Delivered,
            IsDeleted = true,
            OrderItems =
            [
                new OrderItem { SupplementId = seed.SupplementB.Id, Quantity = 1, UnitPrice = 70m }
            ]
        };

        context.Orders.AddRange(visibleOrder, deletedOrder);
        await context.SaveChangesAsync();

        var result = await repository.GetPagedAsync(new OrderFilter
        {
            PageNumber = 1,
            PageSize = 10
        }, CancellationToken.None);

        Assert.Equal(1, result.TotalCount);
        Assert.Single(result.Items);
        Assert.Equal(visibleOrder.Id, result.Items[0].Id);
    }

    [Fact]
    public async Task GetUserOrdersPagedAsync_ShouldApplyStatusAndSort()
    {
        await using var context = TestDbContextFactory.Create();
        var seed = await SeedBaseAsync(context);
        var repository = new OrderRepository(context);

        var deliveredHigher = new Order
        {
            UserId = seed.UserJohn.Id,
            TotalAmount = 80m,
            PurchaseDate = DateTime.UtcNow.AddDays(-1),
            Status = OrderStatus.Delivered,
            OrderItems =
            [
                new OrderItem { SupplementId = seed.SupplementA.Id, Quantity = 2, UnitPrice = 40m }
            ]
        };
        var deliveredLower = new Order
        {
            UserId = seed.UserJohn.Id,
            TotalAmount = 30m,
            PurchaseDate = DateTime.UtcNow.AddDays(-2),
            Status = OrderStatus.Delivered,
            OrderItems =
            [
                new OrderItem { SupplementId = seed.SupplementB.Id, Quantity = 1, UnitPrice = 30m }
            ]
        };
        var processing = new Order
        {
            UserId = seed.UserJohn.Id,
            TotalAmount = 100m,
            PurchaseDate = DateTime.UtcNow.AddDays(-3),
            Status = OrderStatus.Processing,
            OrderItems =
            [
                new OrderItem { SupplementId = seed.SupplementA.Id, Quantity = 2, UnitPrice = 50m }
            ]
        };
        var deletedDelivered = new Order
        {
            UserId = seed.UserJohn.Id,
            TotalAmount = 999m,
            PurchaseDate = DateTime.UtcNow.AddDays(-4),
            Status = OrderStatus.Delivered,
            IsDeleted = true,
            OrderItems =
            [
                new OrderItem { SupplementId = seed.SupplementB.Id, Quantity = 3, UnitPrice = 333m }
            ]
        };

        context.Orders.AddRange(deliveredHigher, deliveredLower, processing, deletedDelivered);
        await context.SaveChangesAsync();

        var result = await repository.GetUserOrdersPagedAsync(seed.UserJohn.Id, new OrderFilter
        {
            Status = OrderStatus.Delivered,
            OrderBy = "amount",
            Descending = true,
            PageNumber = 1,
            PageSize = 10
        }, CancellationToken.None);

        Assert.Equal(2, result.TotalCount);
        Assert.Equal(2, result.Items.Count);
        Assert.Equal(deliveredHigher.Id, result.Items[0].Id);
        Assert.Equal(deliveredLower.Id, result.Items[1].Id);
    }

    [Fact]
    public async Task GetSupplementsByIdsAsync_ShouldExcludeSoftDeletedSupplements()
    {
        await using var context = TestDbContextFactory.Create();
        var seed = await SeedBaseAsync(context);
        var repository = new OrderRepository(context);

        seed.SupplementB.IsDeleted = true;
        await context.SaveChangesAsync();

        var supplements = await repository.GetSupplementsByIdsAsync(
            [seed.SupplementA.Id, seed.SupplementB.Id],
            CancellationToken.None);

        Assert.Single(supplements);
        Assert.Equal(seed.SupplementA.Id, supplements[0].Id);
    }

    private static async Task<(User UserJohn, User UserAna, Supplement SupplementA, Supplement SupplementB)> SeedBaseAsync(
        Stronghold.Infrastructure.Data.StrongholdDbContext context)
    {
        var userJohn = new User
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
        var userAna = new User
        {
            FirstName = "Ana",
            LastName = "Smith",
            Username = "ana",
            Email = "ana@example.com",
            PhoneNumber = "062222222",
            Role = Role.GymMember,
            Gender = Gender.Female,
            PasswordHash = "hash"
        };

        var category = new SupplementCategory
        {
            Name = "Protein"
        };
        var supplier = new Supplier
        {
            Name = "Supplier A"
        };
        var supplementA = new Supplement
        {
            Name = "Whey",
            Price = 40m,
            SupplementCategory = category,
            Supplier = supplier
        };
        var supplementB = new Supplement
        {
            Name = "Creatine",
            Price = 30m,
            SupplementCategory = category,
            Supplier = supplier
        };

        context.Users.AddRange(userJohn, userAna);
        context.SupplementCategories.Add(category);
        context.Suppliers.Add(supplier);
        context.Supplements.AddRange(supplementA, supplementB);
        await context.SaveChangesAsync();

        return (userJohn, userAna, supplementA, supplementB);
    }
}
