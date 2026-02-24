using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Appointments.DTOs;

using Stronghold.Application.Features.Trainers.Commands;
using Stronghold.Application.Features.Trainers.DTOs;
using Stronghold.Application.Features.Trainers.Queries;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/trainers")]
[Authorize]
public class TrainerController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly IAdminActivityService _activityService;
    private readonly ICurrentUserService _currentUserService;

    public TrainerController(
        IMediator mediator,
        IAdminActivityService activityService,
        ICurrentUserService currentUserService)
    {
        _mediator = mediator;
        _activityService = activityService;
        _currentUserService = currentUserService;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<TrainerResponse>>> GetAllPagedAsync([FromQuery] TrainerFilter filter)
    {
        var result = await _mediator.Send(new GetPagedTrainersQuery { Filter = filter });
        return Ok(result);
    }

    [HttpGet("all")]
    public async Task<ActionResult<IEnumerable<TrainerResponse>>> GetAllAsync([FromQuery] TrainerFilter filter)
    {
        var result = await _mediator.Send(new GetTrainersQuery { Filter = filter });
        return Ok(result);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<TrainerResponse>> GetById(int id)
    {
        var result = await _mediator.Send(new GetTrainerByIdQuery { Id = id });
        return Ok(result);
    }

    [HttpPost]
    public async Task<ActionResult<TrainerResponse>> Create([FromBody] CreateTrainerCommand command)
    {
        var result = await _mediator.Send(command);
        await LogAddActivityAsync(result.Id);
        return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<TrainerResponse>> Update(int id, [FromBody] UpdateTrainerCommand command)
    {
        command.Id = id;
        var result = await _mediator.Send(command);
        return Ok(result);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        await _mediator.Send(new DeleteTrainerCommand { Id = id });
        await LogDeleteActivityAsync(id);
        return NoContent();
    }

    [HttpPost("{id}/appointments")]
    public async Task<ActionResult<AppointmentResponse>> BookAppointment(int id, [FromBody] BookAppointmentRequest request)
    {
        var result = await _mediator.Send(new BookTrainerAppointmentCommand
        {
            TrainerId = id,
            Date = request.Date
        });

        return Ok(result);
    }

    [HttpGet("{id}/available-hours")]
    public async Task<ActionResult<IEnumerable<int>>> GetAvailableHours(int id, [FromQuery] DateTime date)
    {
        var result = await _mediator.Send(new GetTrainerAvailableHoursQuery
        {
            TrainerId = id,
            Date = date
        });

        return Ok(result);
    }

    private async Task LogAddActivityAsync(int id)
    {
        if (!_currentUserService.UserId.HasValue)
        {
            return;
        }

        var adminUsername = _currentUserService.Username ?? "admin";
        await _activityService.LogAddAsync(_currentUserService.UserId.Value, adminUsername, nameof(Trainer), id);
    }

    private async Task LogDeleteActivityAsync(int id)
    {
        if (!_currentUserService.UserId.HasValue)
        {
            return;
        }

        var adminUsername = _currentUserService.Username ?? "admin";
        await _activityService.LogDeleteAsync(_currentUserService.UserId.Value, adminUsername, nameof(Trainer), id);
    }
}
