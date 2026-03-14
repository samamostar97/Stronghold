using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;

namespace Stronghold.Application.Features.AuditLogs.GetAuditLogs;

public class GetAuditLogsQueryHandler : IRequestHandler<GetAuditLogsQuery, PagedResult<AuditLogResponse>>
{
    private readonly IAuditLogRepository _auditLogRepository;

    public GetAuditLogsQueryHandler(IAuditLogRepository auditLogRepository)
    {
        _auditLogRepository = auditLogRepository;
    }

    public async Task<PagedResult<AuditLogResponse>> Handle(GetAuditLogsQuery request, CancellationToken cancellationToken)
    {
        IQueryable<AuditLog> query = _auditLogRepository.QueryAll()
            .Include(a => a.AdminUser);

        if (!string.IsNullOrWhiteSpace(request.EntityType))
            query = query.Where(a => a.EntityType == request.EntityType);

        if (!string.IsNullOrWhiteSpace(request.Search))
            query = query.Where(a => a.EntityType.Contains(request.Search)
                || a.AdminUser.Username.Contains(request.Search));

        var totalCount = await query.CountAsync(cancellationToken);

        var auditLogs = await query
            .OrderByDescending(a => a.CreatedAt)
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .ToListAsync(cancellationToken);

        return new PagedResult<AuditLogResponse>
        {
            Items = auditLogs.Select(AuditLogMappings.ToResponse).ToList(),
            TotalCount = totalCount,
            CurrentPage = request.PageNumber,
            PageSize = request.PageSize,
            TotalPages = (int)Math.Ceiling(totalCount / (double)request.PageSize)
        };
    }
}
