using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Features.Appointments.AdminCreateAppointment;
using Stronghold.Application.Features.Appointments.ApproveAppointment;
using Stronghold.Application.Features.Appointments.CompleteAppointment;
using Stronghold.Application.Features.Appointments.CreateAppointment;
using Stronghold.Application.Features.Appointments.GetAppointments;
using Stronghold.Application.Features.Appointments.GetMyAppointments;
using Stronghold.Application.Features.Appointments.RejectAppointment;

namespace Stronghold.API.Controllers;

[ApiController]
[Authorize]
[Route("api/appointments")]
public class AppointmentsController : ControllerBase
{
    private readonly IMediator _mediator;

    public AppointmentsController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpPost]
    public async Task<IActionResult> CreateAppointment([FromBody] CreateAppointmentCommand command)
    {
        var result = await _mediator.Send(command);
        return StatusCode(201, result);
    }

    [HttpPost("/api/admin/appointments")]
    public async Task<IActionResult> AdminCreateAppointment([FromBody] AdminCreateAppointmentCommand command)
    {
        var result = await _mediator.Send(command);
        return StatusCode(201, result);
    }

    [HttpGet("my")]
    public async Task<IActionResult> GetMyAppointments([FromQuery] GetMyAppointmentsQuery query)
    {
        var result = await _mediator.Send(query);
        return Ok(result);
    }

    [HttpGet]
    public async Task<IActionResult> GetAppointments([FromQuery] GetAppointmentsQuery query)
    {
        var result = await _mediator.Send(query);
        return Ok(result);
    }

    [HttpPut("{id:int}/approve")]
    public async Task<IActionResult> ApproveAppointment(int id)
    {
        var result = await _mediator.Send(new ApproveAppointmentCommand { Id = id });
        return Ok(result);
    }

    [HttpPut("{id:int}/reject")]
    public async Task<IActionResult> RejectAppointment(int id)
    {
        var result = await _mediator.Send(new RejectAppointmentCommand { Id = id });
        return Ok(result);
    }

    [HttpPut("{id:int}/complete")]
    public async Task<IActionResult> CompleteAppointment(int id)
    {
        var result = await _mediator.Send(new CompleteAppointmentCommand { Id = id });
        return Ok(result);
    }
}
