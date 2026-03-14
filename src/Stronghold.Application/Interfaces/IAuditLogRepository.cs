using Stronghold.Domain.Entities;

namespace Stronghold.Application.Interfaces;

public interface IAuditLogRepository
{
    Task<AuditLog?> GetByIdAsync(int id);
    IQueryable<AuditLog> Query();
    IQueryable<AuditLog> QueryAll();
    Task AddAsync(AuditLog auditLog);
    Task SaveChangesAsync();
}
