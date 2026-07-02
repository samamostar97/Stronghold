using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Stronghold.Infrastructure.Data;

/// <summary>
/// Izvrsava migracije i seed pri startu API-ja. SQL Serveru u Dockeru treba 20-60s
/// na svjezoj masini, pa se pokusava vise puta prije odustajanja.
/// </summary>
public static class DatabaseInitializer
{
    private const int MaxAttempts = 30;
    private static readonly TimeSpan RetryDelay = TimeSpan.FromSeconds(5);

    public static async Task InitializeAsync(StrongholdDbContext db, ILogger logger)
    {
        for (var attempt = 1; attempt <= MaxAttempts; attempt++)
        {
            try
            {
                await db.Database.MigrateAsync();
                logger.LogInformation("Migracije primijenjene (pokusaj {Attempt}).", attempt);
                break;
            }
            catch (Exception ex) when (attempt < MaxAttempts)
            {
                logger.LogWarning("Baza jos nije spremna (pokusaj {Attempt}/{Max}): {Message}",
                    attempt, MaxAttempts, ex.Message);
                await Task.Delay(RetryDelay);
            }
        }

        await DatabaseSeeder.SeedAsync(db, logger);
    }
}
