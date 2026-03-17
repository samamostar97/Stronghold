using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;
using Stronghold.Infrastructure.Persistence;

namespace Stronghold.Infrastructure.Repositories;

public class SeminarRepository : Repository<Seminar>, ISeminarRepository
{
    public SeminarRepository(StrongholdDbContext context) : base(context) { }

    public async Task<Seminar?> GetByIdWithRegistrationsAsync(int id)
    {
        return await Query()
            .Include(s => s.Registrations.Where(r => !r.IsDeleted))
            .ThenInclude(r => r.User)
            .FirstOrDefaultAsync(s => s.Id == id);
    }
}
