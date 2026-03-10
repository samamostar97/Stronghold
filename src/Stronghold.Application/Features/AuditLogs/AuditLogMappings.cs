using Stronghold.Domain.Entities;

namespace Stronghold.Application.Features.AuditLogs;

public static class AuditLogMappings
{
    public static AuditLogResponse ToResponse(AuditLog auditLog)
    {
        return new AuditLogResponse
        {
            Id = auditLog.Id,
            AdminUserId = auditLog.AdminUserId,
            AdminUsername = auditLog.AdminUser?.Username ?? string.Empty,
            Action = auditLog.Action,
            EntityType = auditLog.EntityType,
            EntityId = auditLog.EntityId,
            EntitySnapshot = auditLog.EntitySnapshot,
            CreatedAt = auditLog.CreatedAt,
            CanUndoUntil = auditLog.CanUndoUntil,
            CanUndo = auditLog.CanUndoUntil > DateTime.UtcNow
        };
    }
}
