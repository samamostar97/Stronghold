using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;
using Stronghold.Infrastructure.Persistence;

namespace Stronghold.Infrastructure.Repositories;

public class AuditLogRepository : IAuditLogRepository
{
    private readonly StrongholdDbContext _context;
    private readonly DbSet<AuditLog> _dbSet;

    public AuditLogRepository(StrongholdDbContext context)
    {
        _context = context;
        _dbSet = context.Set<AuditLog>();
    }

    public async Task<AuditLog?> GetByIdAsync(int id)
    {
        return await _dbSet.FirstOrDefaultAsync(a => a.Id == id);
    }

    public IQueryable<AuditLog> Query()
    {
        return _dbSet.AsQueryable();
    }

    public IQueryable<AuditLog> QueryAll()
    {
        return _dbSet.IgnoreQueryFilters().AsQueryable();
    }

    public async Task AddAsync(AuditLog auditLog)
    {
        await _dbSet.AddAsync(auditLog);
    }

    public async Task SaveChangesAsync()
    {
        await _context.SaveChangesAsync();
    }
}
