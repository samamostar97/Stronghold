namespace Stronghold.Application.Interfaces;

public interface IAuditService
{
    Task LogDeleteAsync(int adminUserId, string entityType, int entityId, object entitySnapshot);
}
