using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Seminars.Commands;
using Stronghold.Application.Features.Seminars.DTOs;
using Stronghold.Application.Features.Seminars.Queries;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/seminars")]
[Authorize]
public class SeminarController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly IAdminActivityService _activityService;
    private readonly ICurrentUserService _currentUserService;

    public SeminarController(
        IMediator mediator,
        IAdminActivityService activityService,
        ICurrentUserService currentUserService)
    {
        _mediator = mediator;
        _activityService = activityService;
        _currentUserService = currentUserService;
    }

    [HttpGet("upcoming")]
    public async Task<ActionResult<IReadOnlyList<UserSeminarResponse>>> GetUpcomingSeminarsAsync()
    {
        var result = await _mediator.Send(new GetUpcomingSeminarsQuery());
        return Ok(result);
    }

    [HttpPost("{id}/attend")]
    public async Task<ActionResult> AttendSeminarAsync(int id)
    {
        await _mediator.Send(new AttendSeminarCommand { SeminarId = id });
        return NoContent();
    }

    [HttpDelete("{id}/attend")]
    public async Task<ActionResult> CancelAttendanceAsync(int id)
    {
        await _mediator.Send(new CancelSeminarAttendanceCommand { SeminarId = id });
        return NoContent();
    }

    [HttpPatch("{id}/cancel")]
    public async Task<ActionResult> CancelSeminarAsync(int id)
    {
        await _mediator.Send(new CancelSeminarCommand { Id = id });
        return NoContent();
    }

    [HttpGet("all")]
    public async Task<ActionResult<IReadOnlyList<SeminarResponse>>> GetAllAsync([FromQuery] SeminarFilter filter)
    {
        var result = await _mediator.Send(new GetSeminarsQuery { Filter = filter });
        return Ok(result);
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<SeminarResponse>>> GetAllPagedAsync([FromQuery] SeminarFilter filter)
    {
        var result = await _mediator.Send(new GetPagedSeminarsQuery { Filter = filter });
        return Ok(result);
    }

    [HttpPost]
    public async Task<ActionResult<SeminarResponse>> Create([FromBody] CreateSeminarCommand command)
    {
        var result = await _mediator.Send(command);
        await LogAddActivityAsync(result.Id);
        return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<SeminarResponse>> Update(int id, [FromBody] UpdateSeminarCommand command)
    {
        command.Id = id;
        var result = await _mediator.Send(command);
        return Ok(result);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<SeminarResponse>> GetById(int id)
    {
        var result = await _mediator.Send(new GetSeminarByIdQuery { Id = id });
        return Ok(result);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        await _mediator.Send(new DeleteSeminarCommand { Id = id });
        await LogDeleteActivityAsync(id);
        return NoContent();
    }

    [HttpGet("{id}/attendees")]
    public async Task<ActionResult<IReadOnlyList<SeminarAttendeeResponse>>> GetSeminarAttendees(int id)
    {
        var result = await _mediator.Send(new GetSeminarAttendeesQuery { SeminarId = id });
        return Ok(result);
    }

    private async Task LogAddActivityAsync(int id)
    {
        if (!_currentUserService.UserId.HasValue)
        {
            return;
        }

        var adminUsername = _currentUserService.Username ?? "admin";
        await _activityService.LogAddAsync(_currentUserService.UserId.Value, adminUsername, nameof(Seminar), id);
    }

    private async Task LogDeleteActivityAsync(int id)
    {
        if (!_currentUserService.UserId.HasValue)
        {
            return;
        }

        var adminUsername = _currentUserService.Username ?? "admin";
        await _activityService.LogDeleteAsync(_currentUserService.UserId.Value, adminUsername, nameof(Seminar), id);
    }
}
