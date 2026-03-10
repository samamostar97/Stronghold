using Microsoft.EntityFrameworkCore;
using Stronghold.Domain.Entities;
using Stronghold.Domain.Enums;

namespace Stronghold.Infrastructure.Persistence.Seeding;

public static class AdminSeeder
{
    public static async Task SeedAsync(StrongholdDbContext context)
    {
        if (await context.Users.AnyAsync(u => u.Role == Role.Admin))
            return;

        var username = Environment.GetEnvironmentVariable("ADMIN_USERNAME") ?? "desktop";
        var password = Environment.GetEnvironmentVariable("ADMIN_PASSWORD") ?? "test";

        var admin = new User
        {
            FirstName = "Admin",
            LastName = "Admin",
            Username = username,
            Email = "admin@stronghold.com",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(password),
            Role = Role.Admin,
            CreatedAt = DateTime.UtcNow
        };

        await context.Users.AddAsync(admin);
        await context.SaveChangesAsync();
    }
}
