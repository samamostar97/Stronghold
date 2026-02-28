using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.Features.AdminActivities.Commands;
using Stronghold.Application.Features.Appointments.Commands;
using Stronghold.Application.Features.Appointments.DTOs;
using Stronghold.Application.Features.Appointments.Queries;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/appointments")]
    [Authorize]
    public class AppointmentController : ControllerBase
    {
        private readonly IMediator _mediator;

        public AppointmentController(IMediator mediator)
        {
            _mediator = mediator;
        }

        [HttpGet("my")]
        public async Task<ActionResult<PagedResult<AppointmentResponse>>> GetMyAppointments([FromQuery] AppointmentFilter filter)
        {
            var result = await _mediator.Send(new GetMyAppointmentsQuery { Filter = filter });
            return Ok(result);
        }

        [HttpGet("admin")]
        public async Task<ActionResult<PagedResult<AdminAppointmentResponse>>> GetAllAppointments([FromQuery] AppointmentFilter filter)
        {
            var result = await _mediator.Send(new GetAdminAppointmentsQuery { Filter = filter });
            return Ok(result);
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult> Cancel(int id)
        {
            await _mediator.Send(new CancelMyAppointmentCommand { AppointmentId = id });
            return NoContent();
        }

        [HttpPost("admin")]
        public async Task<ActionResult> AdminCreate([FromBody] AdminCreateAppointmentCommand command)
        {
            var id = await _mediator.Send(command);
            await _mediator.Send(new LogAdminActivityCommand
            {
                Action = AdminActivityLogAction.Add,
                EntityType = "Appointment",
                EntityId = id
            });

            return CreatedAtAction(nameof(GetAllAppointments), new { id }, new { id });
        }

        [HttpPut("admin/{id}")]
        public async Task<ActionResult> AdminUpdate(int id, [FromBody] AdminUpdateAppointmentCommand command)
        {
            command.Id = id;
            await _mediator.Send(command);
            return NoContent();
        }

        [HttpDelete("admin/{id}")]
        public async Task<ActionResult> AdminDelete(int id)
        {
            await _mediator.Send(new AdminDeleteAppointmentCommand { Id = id });
            await _mediator.Send(new LogAdminActivityCommand
            {
                Action = AdminActivityLogAction.Delete,
                EntityType = "Appointment",
                EntityId = id
            });

            return NoContent();
        }
    }
}
