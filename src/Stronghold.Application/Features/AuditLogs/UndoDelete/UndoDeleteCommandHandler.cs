using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.AuditLogs.UndoDelete;

public class UndoDeleteCommandHandler : IRequestHandler<UndoDeleteCommand, Unit>
{
    private readonly IAuditLogRepository _auditLogRepository;
    private readonly IUndoService _undoService;

    public UndoDeleteCommandHandler(IAuditLogRepository auditLogRepository, IUndoService undoService)
    {
        _auditLogRepository = auditLogRepository;
        _undoService = undoService;
    }

    public async Task<Unit> Handle(UndoDeleteCommand request, CancellationToken cancellationToken)
    {
        var auditLog = await _auditLogRepository.GetByIdAsync(request.Id)
            ?? throw new NotFoundException("Audit log", request.Id);

        if (auditLog.CanUndoUntil < DateTime.UtcNow)
            throw new InvalidOperationException("Vrijeme za poništavanje ove akcije je isteklo.");

        await _undoService.UndoDeleteAsync(auditLog.EntityType, auditLog.EntityId);

        return Unit.Value;
    }
}
