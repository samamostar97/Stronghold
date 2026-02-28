using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.Features.AdminActivities.Commands;
using Stronghold.Application.Features.SupplementCategories.Commands;
using Stronghold.Application.Features.SupplementCategories.DTOs;
using Stronghold.Application.Features.SupplementCategories.Queries;
using Stronghold.Core.Entities;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/supplement-categories")]
[Authorize]
public class SupplementCategoryController : ControllerBase
{
    private readonly IMediator _mediator;

    public SupplementCategoryController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<SupplementCategoryResponse>>> GetAllPagedAsync([FromQuery] SupplementCategoryFilter filter)
    {
        var result = await _mediator.Send(new GetPagedSupplementCategoriesQuery { Filter = filter });
        return Ok(result);
    }

    [HttpGet("all")]
    public async Task<ActionResult<IEnumerable<SupplementCategoryResponse>>> GetAllAsync([FromQuery] SupplementCategoryFilter filter)
    {
        var result = await _mediator.Send(new GetSupplementCategoriesQuery { Filter = filter });
        return Ok(result);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<SupplementCategoryResponse>> GetById(int id)
    {
        var result = await _mediator.Send(new GetSupplementCategoryByIdQuery { Id = id });
        return Ok(result);
    }

    [HttpPost]
    public async Task<ActionResult<SupplementCategoryResponse>> Create([FromBody] CreateSupplementCategoryCommand command)
    {
        var result = await _mediator.Send(command);
        await _mediator.Send(new LogAdminActivityCommand
        {
            Action = AdminActivityLogAction.Add,
            EntityType = nameof(SupplementCategory),
            EntityId = result.Id
        });
        return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<SupplementCategoryResponse>> Update(int id, [FromBody] UpdateSupplementCategoryCommand command)
    {
        command.Id = id;
        var result = await _mediator.Send(command);
        return Ok(result);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        await _mediator.Send(new DeleteSupplementCategoryCommand { Id = id });
        await _mediator.Send(new LogAdminActivityCommand
        {
            Action = AdminActivityLogAction.Delete,
            EntityType = nameof(SupplementCategory),
            EntityId = id
        });
        return NoContent();
    }
}
