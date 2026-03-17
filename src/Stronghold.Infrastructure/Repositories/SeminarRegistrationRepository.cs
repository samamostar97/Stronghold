using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;
using Stronghold.Infrastructure.Persistence;

namespace Stronghold.Infrastructure.Repositories;

public class SeminarRegistrationRepository : Repository<SeminarRegistration>, ISeminarRegistrationRepository
{
    public SeminarRegistrationRepository(StrongholdDbContext context) : base(context) { }

    public async Task<bool> IsUserRegisteredAsync(int seminarId, int userId)
    {
        return await Query().AnyAsync(r => r.SeminarId == seminarId && r.UserId == userId);
    }

    public async Task<int> GetRegistrationCountAsync(int seminarId)
    {
        return await Query().CountAsync(r => r.SeminarId == seminarId);
    }
}
