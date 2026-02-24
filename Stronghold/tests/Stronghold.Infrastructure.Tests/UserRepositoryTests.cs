using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Features.Users.DTOs;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;
using Stronghold.Infrastructure.Repositories;
using Stronghold.Infrastructure.Tests.TestHelpers;

namespace Stronghold.Infrastructure.Tests;

public class UserRepositoryTests
{
    [Fact]
    public async Task GetPagedAsync_ShouldSearchByUsername_AndExcludeDeletedAndAdmin()
    {
        await using var context = TestDbContextFactory.Create();
        var repository = new UserRepository(context);

        var visibleUser = new User
        {
            FirstName = "Amar",
            LastName = "Kovac",
            Username = "amar_fit",
            Email = "amar@example.com",
            PhoneNumber = "061111111",
            Role = Role.GymMember,
            Gender = Gender.Male,
            PasswordHash = "hash"
        };
        var deletedUser = new User
        {
            FirstName = "Deleted",
            LastName = "User",
            Username = "amar_deleted",
            Email = "deleted@example.com",
            PhoneNumber = "061222222",
            Role = Role.GymMember,
            Gender = Gender.Female,
            PasswordHash = "hash",
            IsDeleted = true
        };
        var adminUser = new User
        {
            FirstName = "Admin",
            LastName = "User",
            Username = "amar_admin",
            Email = "admin@example.com",
            PhoneNumber = "061333333",
            Role = Role.Admin,
            Gender = Gender.Male,
            PasswordHash = "hash"
        };

        context.Users.AddRange(visibleUser, deletedUser, adminUser);
        await context.SaveChangesAsync();

        var result = await repository.GetPagedAsync(new UserFilter
        {
            Name = "amar_",
            PageNumber = 1,
            PageSize = 10
        }, CancellationToken.None);

        Assert.Equal(1, result.TotalCount);
        Assert.Single(result.Items);
        Assert.Equal(visibleUser.Id, result.Items[0].Id);
    }

    [Fact]
    public async Task DeleteAsync_ShouldSoftDeleteEntity()
    {
        await using var context = TestDbContextFactory.Create();
        var repository = new UserRepository(context);

        var user = new User
        {
            FirstName = "Lejla",
            LastName = "Basic",
            Username = "lejla",
            Email = "lejla@example.com",
            PhoneNumber = "062444444",
            Role = Role.GymMember,
            Gender = Gender.Female,
            PasswordHash = "hash"
        };

        await repository.AddAsync(user, CancellationToken.None);
        await repository.DeleteAsync(user, CancellationToken.None);

        var visible = await repository.GetByIdAsync(user.Id, CancellationToken.None);
        var raw = await context.Users
            .IgnoreQueryFilters()
            .SingleAsync(x => x.Id == user.Id);

        Assert.Null(visible);
        Assert.True(raw.IsDeleted);
    }
}
