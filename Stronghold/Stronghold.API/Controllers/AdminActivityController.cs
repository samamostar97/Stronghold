using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Features.AdminActivities.Commands;
using Stronghold.Application.Features.AdminActivities.Queries;
using Stronghold.Application.DTOs.Response;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/admin-activities")]
[Authorize]
public class AdminActivityController : ControllerBase
{
    private readonly IMediator _mediator;

    public AdminActivityController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet("recent")]
    public async Task<ActionResult<IReadOnlyList<AdminActivityResponse>>> GetRecent([FromQuery] int count = 20)
    {
        var result = await _mediator.Send(new GetRecentAdminActivitiesQuery { Count = count });
        return Ok(result);
    }

    [HttpPost("{id:int}/undo")]
    public async Task<ActionResult<AdminActivityResponse>> Undo(int id)
    {
        var result = await _mediator.Send(new UndoAdminActivityCommand { Id = id });
        return Ok(result);
    }
}
