using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Stronghold.Infrastructure.Data;

namespace Stronghold.API.Controllers.Admin;

[ApiController]
[Route("api/admin/dev")]
[Authorize(Roles = "Admin")] // change to "Administrator" if that's your role string
public class AdminDevController : ControllerBase
{
    private readonly StrongholdDbContext _db;
    private readonly IWebHostEnvironment _env;

    public AdminDevController(StrongholdDbContext db, IWebHostEnvironment env)
    {
        _db = db;
        _env = env;
    }

    /// <summary>
    /// DEV ONLY: Drops the database, recreates it, and runs the DatabaseSeeder.
    /// </summary>
    [HttpPost("reset-database")]
    public async Task<IActionResult> ResetDatabase()
    {
        if (!_env.IsDevelopment())
            return Forbid("Reset is allowed only in Development environment.");

        // Drop + recreate schema based on migrations
        await _db.Database.EnsureDeletedAsync();
        await _db.Database.MigrateAsync();

        // Reseed
        var seeder = new DatabaseSeeder(_db);
        await seeder.SeedAsync();

        return Ok(new { message = "Database reset complete (dropped, migrated, reseeded)." });
    }
}
