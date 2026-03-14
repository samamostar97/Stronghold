using Microsoft.EntityFrameworkCore;
using Stronghold.Domain.Entities;

namespace Stronghold.Infrastructure.Persistence.Seeding;

public static class LevelSeeder
{
    public static async Task SeedAsync(StrongholdDbContext context)
    {
        if (await context.Levels.AnyAsync())
            return;

        var levels = new List<Level>
        {
            new() { Name = "Početnik", MinXP = 0, MaxXP = 99, BadgeImageUrl = "/level-badges/d4e5f6a7-4444-4444-4444-000000000001.png" },
            new() { Name = "Redovni", MinXP = 100, MaxXP = 249, BadgeImageUrl = "/level-badges/d4e5f6a7-4444-4444-4444-000000000002.png" },
            new() { Name = "Posvećeni", MinXP = 250, MaxXP = 499, BadgeImageUrl = "/level-badges/d4e5f6a7-4444-4444-4444-000000000003.png" },
            new() { Name = "Napredni", MinXP = 500, MaxXP = 999, BadgeImageUrl = "/level-badges/d4e5f6a7-4444-4444-4444-000000000004.png" },
            new() { Name = "Elitni", MinXP = 1000, MaxXP = 1999, BadgeImageUrl = "/level-badges/d4e5f6a7-4444-4444-4444-000000000005.png" },
            new() { Name = "Legenda", MinXP = 2000, MaxXP = int.MaxValue, BadgeImageUrl = "/level-badges/d4e5f6a7-4444-4444-4444-000000000006.png" }
        };

        await context.Levels.AddRangeAsync(levels);
        await context.SaveChangesAsync();
    }
}
