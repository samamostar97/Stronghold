using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.Features.AdminActivities.Commands;
using Stronghold.Application.Features.Appointments.DTOs;

using Stronghold.Application.Features.Nutritionists.Commands;
using Stronghold.Application.Features.Nutritionists.DTOs;
using Stronghold.Application.Features.Nutritionists.Queries;
using Stronghold.Core.Entities;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/nutritionists")]
[Authorize]
public class NutritionistController : ControllerBase
{
    private readonly IMediator _mediator;

    public NutritionistController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<NutritionistResponse>>> GetAllPagedAsync([FromQuery] NutritionistFilter filter)
    {
        var result = await _mediator.Send(new GetPagedNutritionistsQuery { Filter = filter });
        return Ok(result);
    }

    [HttpGet("all")]
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
        await _mediator.Send(new LogAdminActivityCommand
        {
            Action = AdminActivityLogAction.Add,
            EntityType = nameof(Nutritionist),
            EntityId = result.Id
        });
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
        await _mediator.Send(new LogAdminActivityCommand
        {
            Action = AdminActivityLogAction.Delete,
            EntityType = nameof(Nutritionist),
            EntityId = id
        });
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

}
