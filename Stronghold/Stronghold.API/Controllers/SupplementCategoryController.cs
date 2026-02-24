using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.Features.SupplementCategories.Commands;
using Stronghold.Application.Features.SupplementCategories.DTOs;
using Stronghold.Application.Features.SupplementCategories.Queries;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/supplement-categories")]
[Authorize]
public class SupplementCategoryController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly IAdminActivityService _activityService;
    private readonly ICurrentUserService _currentUserService;

    public SupplementCategoryController(
        IMediator mediator,
        IAdminActivityService activityService,
        ICurrentUserService currentUserService)
    {
        _mediator = mediator;
        _activityService = activityService;
        _currentUserService = currentUserService;
    }

    [HttpGet("GetAllPaged")]
    public async Task<ActionResult<PagedResult<SupplementCategoryResponse>>> GetAllPagedAsync([FromQuery] SupplementCategoryFilter filter)
    {
        var result = await _mediator.Send(new GetPagedSupplementCategoriesQuery { Filter = filter });
        return Ok(result);
    }

    [HttpGet("GetAll")]
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
        await LogAddActivityAsync(result.Id);
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
        await LogDeleteActivityAsync(id);
        return NoContent();
    }

    private async Task LogAddActivityAsync(int id)
    {
        if (!_currentUserService.UserId.HasValue)
        {
            return;
        }

        var adminUsername = _currentUserService.Username ?? "admin";
        await _activityService.LogAddAsync(_currentUserService.UserId.Value, adminUsername, nameof(SupplementCategory), id);
    }

    private async Task LogDeleteActivityAsync(int id)
    {
        if (!_currentUserService.UserId.HasValue)
        {
            return;
        }

        var adminUsername = _currentUserService.Username ?? "admin";
        await _activityService.LogDeleteAsync(_currentUserService.UserId.Value, adminUsername, nameof(SupplementCategory), id);
    }
}
