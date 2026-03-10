using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Features.AuditLogs.GetAuditLogs;
using Stronghold.Application.Features.AuditLogs.UndoDelete;

namespace Stronghold.API.Controllers;

[ApiController]
[Authorize]
[Route("api/audit-logs")]
public class AuditLogsController : ControllerBase
{
    private readonly IMediator _mediator;

    public AuditLogsController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<IActionResult> GetAuditLogs([FromQuery] GetAuditLogsQuery query)
    {
        var result = await _mediator.Send(query);
        return Ok(result);
    }

    [HttpPost("{id:int}/undo")]
    public async Task<IActionResult> UndoDelete(int id)
    {
        await _mediator.Send(new UndoDeleteCommand { Id = id });
        return NoContent();
    }
}
