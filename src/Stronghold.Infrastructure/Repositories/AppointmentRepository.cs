using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;
using Stronghold.Domain.Enums;
using Stronghold.Infrastructure.Persistence;

namespace Stronghold.Infrastructure.Repositories;

public class AppointmentRepository : Repository<Appointment>, IAppointmentRepository
{
    public AppointmentRepository(StrongholdDbContext context) : base(context) { }

    public async Task<Appointment?> GetByIdWithDetailsAsync(int id)
    {
        return await QueryAll()
            .Include(a => a.User)
            .Include(a => a.Staff)
            .FirstOrDefaultAsync(a => a.Id == id);
    }

    public async Task<bool> HasConflictAsync(int staffId, DateTime scheduledAt, int? excludeId = null)
    {
        var query = _dbSet.Where(a =>
            a.StaffId == staffId
            && a.ScheduledAt == scheduledAt
            && a.Status != AppointmentStatus.Rejected);

        if (excludeId.HasValue)
            query = query.Where(a => a.Id != excludeId.Value);

        return await query.AnyAsync();
    }
}
