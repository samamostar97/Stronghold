using Microsoft.EntityFrameworkCore;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Tests.TestHelpers;

internal static class TestDbContextFactory
{
    public static StrongholdDbContext Create()
    {
        var options = new DbContextOptionsBuilder<StrongholdDbContext>()
            .UseInMemoryDatabase(databaseName: $"stronghold-tests-{Guid.NewGuid():N}")
            .Options;

        return new StrongholdDbContext(options);
    }
}
