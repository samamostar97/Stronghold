using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Features.Staff.CreateStaff;
using Stronghold.Application.Features.Staff.DeleteStaff;
using Stronghold.Application.Features.Staff.GetStaff;
using Stronghold.Application.Features.Staff.GetStaffById;
using Stronghold.Application.Features.Staff.UpdateStaff;
using Stronghold.Application.Features.Staff.UpdateStaffImage;
using Stronghold.Application.Features.Appointments.GetStaffAppointments;
using Stronghold.Application.Features.Appointments.GetAvailableSlots;

namespace Stronghold.API.Controllers;

[ApiController]
[Authorize]
[Route("api/staff")]
public class StaffController : ControllerBase
{
    private readonly IMediator _mediator;

    public StaffController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<IActionResult> GetStaff([FromQuery] GetStaffQuery query)
    {
        var result = await _mediator.Send(query);
        return Ok(result);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetStaffById(int id)
    {
        var result = await _mediator.Send(new GetStaffByIdQuery { Id = id });
        return Ok(result);
    }

    [HttpPost]
    public async Task<IActionResult> CreateStaff([FromBody] CreateStaffCommand command)
    {
        var result = await _mediator.Send(command);
        return StatusCode(201, result);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> UpdateStaff(int id, [FromBody] UpdateStaffCommand command)
    {
        command.Id = id;
        var result = await _mediator.Send(command);
        return Ok(result);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> DeleteStaff(int id)
    {
        await _mediator.Send(new DeleteStaffCommand { Id = id });
        return NoContent();
    }

    [HttpPut("{id:int}/profile-image")]
    public async Task<IActionResult> UpdateStaffImage(int id, IFormFile file)
    {
        var command = new UpdateStaffImageCommand
        {
            Id = id,
            FileStream = file.OpenReadStream(),
            FileName = file.FileName
        };

        var result = await _mediator.Send(command);
        return Ok(result);
    }

    [HttpGet("{id:int}/appointments")]
    public async Task<IActionResult> GetStaffAppointments(int id, [FromQuery] GetStaffAppointmentsQuery query)
    {
        query.StaffId = id;
        var result = await _mediator.Send(query);
        return Ok(result);
    }

    [HttpGet("{id:int}/available-slots")]
    public async Task<IActionResult> GetAvailableSlots(int id, [FromQuery] DateTime date)
    {
        var result = await _mediator.Send(new GetAvailableSlotsQuery { StaffId = id, Date = date });
        return Ok(result);
    }
}
