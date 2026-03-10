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
            new() { Name = "Početnik", MinXP = 0, MaxXP = 99 },
            new() { Name = "Redovni", MinXP = 100, MaxXP = 249 },
            new() { Name = "Posvećeni", MinXP = 250, MaxXP = 499 },
            new() { Name = "Napredni", MinXP = 500, MaxXP = 999 },
            new() { Name = "Elitni", MinXP = 1000, MaxXP = 1999 },
            new() { Name = "Legenda", MinXP = 2000, MaxXP = int.MaxValue }
        };

        await context.Levels.AddRangeAsync(levels);
        await context.SaveChangesAsync();
    }
}
