using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Faqs.Commands;
using Stronghold.Application.Features.Faqs.DTOs;
using Stronghold.Application.Features.Faqs.Queries;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/faq")]
[Authorize]
public class FaqController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly IAdminActivityService _activityService;
    private readonly ICurrentUserService _currentUserService;

    public FaqController(
        IMediator mediator,
        IAdminActivityService activityService,
        ICurrentUserService currentUserService)
    {
        _mediator = mediator;
        _activityService = activityService;
        _currentUserService = currentUserService;
    }

    [HttpGet("GetAllPaged")]
    public async Task<ActionResult<PagedResult<FaqResponse>>> GetAllPagedAsync([FromQuery] FaqFilter filter)
    {
        var result = await _mediator.Send(new GetPagedFaqsQuery { Filter = filter });
        return Ok(result);
    }

    [HttpGet("GetAll")]
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
        await LogAddActivityAsync(result.Id);
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
        await _activityService.LogAddAsync(_currentUserService.UserId.Value, adminUsername, nameof(FAQ), id);
    }

    private async Task LogDeleteActivityAsync(int id)
    {
        if (!_currentUserService.UserId.HasValue)
        {
            return;
        }

        var adminUsername = _currentUserService.Username ?? "admin";
        await _activityService.LogDeleteAsync(_currentUserService.UserId.Value, adminUsername, nameof(FAQ), id);
    }
}
