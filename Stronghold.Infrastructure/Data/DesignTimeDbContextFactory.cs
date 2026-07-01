using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace Stronghold.Infrastructure.Data;

// Koristi se samo za dotnet-ef komande (generisanje migracija) - runtime uzima
// connection string iz environment varijable u Program.cs.
public class DesignTimeDbContextFactory : IDesignTimeDbContextFactory<StrongholdDbContext>
{
    public StrongholdDbContext CreateDbContext(string[] args)
    {
        var connectionString = Environment.GetEnvironmentVariable("CONNECTION_STRING")
            ?? "Server=localhost,1433;Database=210378;User Id=sa;Password=Stronghold123!;TrustServerCertificate=True";

        var options = new DbContextOptionsBuilder<StrongholdDbContext>()
            .UseSqlServer(connectionString)
            .Options;

        return new StrongholdDbContext(options);
    }
}
