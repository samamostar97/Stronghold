using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Features.Nutritionists.Commands;
using Stronghold.Application.Features.Nutritionists.DTOs;
using Stronghold.Application.Features.Nutritionists.Queries;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/nutritionist")]
[Authorize]
public class NutritionistController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly IAdminActivityService _activityService;
    private readonly ICurrentUserService _currentUserService;

    public NutritionistController(
        IMediator mediator,
        IAdminActivityService activityService,
        ICurrentUserService currentUserService)
    {
        _mediator = mediator;
        _activityService = activityService;
        _currentUserService = currentUserService;
    }

    [HttpGet("GetAllPaged")]
    public async Task<ActionResult<PagedResult<NutritionistResponse>>> GetAllPagedAsync([FromQuery] NutritionistFilter filter)
    {
        var result = await _mediator.Send(new GetPagedNutritionistsQuery { Filter = filter });
        return Ok(result);
    }

    [HttpGet("GetAll")]
    public async Task<ActionResult<IEnumerable<NutritionistResponse>>> GetAllAsync([FromQuery] NutritionistFilter filter)
    {
        var result = await _mediator.Send(new GetNutritionistsQuery { Filter = filter });
        return Ok(result);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<NutritionistResponse>> GetById(int id)
    {
        var result = await _mediator.Send(new GetNutritionistByIdQuery { Id = id });
        return Ok(result);
    }

    [HttpPost]
    public async Task<ActionResult<NutritionistResponse>> Create([FromBody] CreateNutritionistCommand command)
    {
        var result = await _mediator.Send(command);
        await LogAddActivityAsync(result.Id);
        return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<NutritionistResponse>> Update(int id, [FromBody] UpdateNutritionistCommand command)
    {
        command.Id = id;
        var result = await _mediator.Send(command);
        return Ok(result);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        await _mediator.Send(new DeleteNutritionistCommand { Id = id });
        await LogDeleteActivityAsync(id);
        return NoContent();
    }

    [HttpPost("{id}/appointments")]
    public async Task<ActionResult<AppointmentResponse>> BookAppointment(int id, [FromBody] BookAppointmentRequest request)
    {
        var result = await _mediator.Send(new BookNutritionistAppointmentCommand
        {
            NutritionistId = id,
            Date = request.Date
        });

        return Ok(result);
    }

    [HttpGet("{id}/available-hours")]
    public async Task<ActionResult<IEnumerable<int>>> GetAvailableHours(int id, [FromQuery] DateTime date)
    {
        var result = await _mediator.Send(new GetNutritionistAvailableHoursQuery
        {
            NutritionistId = id,
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
        await _activityService.LogAddAsync(_currentUserService.UserId.Value, adminUsername, nameof(Nutritionist), id);
    }

    private async Task LogDeleteActivityAsync(int id)
    {
        if (!_currentUserService.UserId.HasValue)
        {
            return;
        }

        var adminUsername = _currentUserService.Username ?? "admin";
        await _activityService.LogDeleteAsync(_currentUserService.UserId.Value, adminUsername, nameof(Nutritionist), id);
    }
}
