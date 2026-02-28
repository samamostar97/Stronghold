using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.Features.AdminActivities.Commands;
using Stronghold.Application.Features.Faqs.Commands;
using Stronghold.Application.Features.Faqs.DTOs;
using Stronghold.Application.Features.Faqs.Queries;
using Stronghold.Core.Entities;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/faqs")]
[Authorize]
public class FaqController : ControllerBase
{
    private readonly IMediator _mediator;

    public FaqController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<FaqResponse>>> GetAllPagedAsync([FromQuery] FaqFilter filter)
    {
        var result = await _mediator.Send(new GetPagedFaqsQuery { Filter = filter });
        return Ok(result);
    }

    [HttpGet("all")]
    public async Task<ActionResult<IEnumerable<FaqResponse>>> GetAllAsync([FromQuery] FaqFilter filter)
    {
        var result = await _mediator.Send(new GetFaqsQuery { Filter = filter });
        return Ok(result);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<FaqResponse>> GetById(int id)
    {
        var result = await _mediator.Send(new GetFaqByIdQuery { Id = id });
        return Ok(result);
    }

    [HttpPost]
    public async Task<ActionResult<FaqResponse>> Create([FromBody] CreateFaqCommand command)
    {
        var result = await _mediator.Send(command);
        await _mediator.Send(new LogAdminActivityCommand
        {
            Action = AdminActivityLogAction.Add,
            EntityType = nameof(FAQ),
            EntityId = result.Id
        });
        return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<FaqResponse>> Update(int id, [FromBody] UpdateFaqCommand command)
    {
        command.Id = id;
        var result = await _mediator.Send(command);
        return Ok(result);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        await _mediator.Send(new DeleteFaqCommand { Id = id });
        await _mediator.Send(new LogAdminActivityCommand
        {
            Action = AdminActivityLogAction.Delete,
            EntityType = nameof(FAQ),
            EntityId = id
        });
        return NoContent();
    }
}
