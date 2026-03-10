using System.Text.Json;
using System.Text.Json.Serialization;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;

namespace Stronghold.Infrastructure.Services;

public class AuditService : IAuditService
{
    private readonly IAuditLogRepository _auditLogRepository;

    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        ReferenceHandler = ReferenceHandler.IgnoreCycles,
        WriteIndented = false
    };

    public AuditService(IAuditLogRepository auditLogRepository)
    {
        _auditLogRepository = auditLogRepository;
    }

    public async Task LogDeleteAsync(int adminUserId, string entityType, int entityId, object entitySnapshot)
    {
        var now = DateTime.UtcNow;
        var snapshot = JsonSerializer.Serialize(entitySnapshot, entitySnapshot.GetType(), JsonOptions);

        var auditLog = new AuditLog
        {
            AdminUserId = adminUserId,
            Action = "Delete",
            EntityType = entityType,
            EntityId = entityId,
            EntitySnapshot = snapshot,
            CreatedAt = now,
            CanUndoUntil = now.AddHours(1)
        };

        await _auditLogRepository.AddAsync(auditLog);
        await _auditLogRepository.SaveChangesAsync();
    }
}
