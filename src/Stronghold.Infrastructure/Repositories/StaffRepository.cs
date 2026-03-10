using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;
using Stronghold.Infrastructure.Persistence;

namespace Stronghold.Infrastructure.Repositories;

public class StaffRepository : Repository<Staff>, IStaffRepository
{
    public StaffRepository(StrongholdDbContext context) : base(context) { }

    public async Task<Staff?> GetByEmailAsync(string email)
    {
        return await _dbSet.FirstOrDefaultAsync(s => s.Email == email);
    }
}
