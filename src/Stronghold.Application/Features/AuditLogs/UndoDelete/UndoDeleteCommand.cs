using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.AuditLogs.UndoDelete;

[AuthorizeRole("Admin")]
public class UndoDeleteCommand : IRequest<Unit>
{
    public int Id { get; set; }
}
