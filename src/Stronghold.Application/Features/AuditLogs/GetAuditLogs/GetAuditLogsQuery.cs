using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.AuditLogs.GetAuditLogs;

[AuthorizeRole("Admin")]
public class GetAuditLogsQuery : BaseQueryFilter, IRequest<PagedResult<AuditLogResponse>>
{
    public string? EntityType { get; set; }
}
