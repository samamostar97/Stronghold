using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Appointments.Commands;
using Stronghold.Application.Features.Appointments.DTOs;
using Stronghold.Application.Features.Appointments.Queries;
using Stronghold.Application.IServices;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/appointments")]
    [Authorize]
    public class AppointmentController : ControllerBase
    {
        private readonly IMediator _mediator;
        private readonly IAdminActivityService _activityService;
        private readonly ICurrentUserService _currentUserService;

        public AppointmentController(
            IMediator mediator,
            IAdminActivityService activityService,
            ICurrentUserService currentUserService)
        {
            _mediator = mediator;
            _activityService = activityService;
            _currentUserService = currentUserService;
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

            if (_currentUserService.UserId.HasValue)
            {
                var adminUsername = _currentUserService.Username ?? "admin";
                await _activityService.LogAddAsync(
                    _currentUserService.UserId.Value,
                    adminUsername,
                    "Appointment",
                    id);
            }

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

            if (_currentUserService.UserId.HasValue)
            {
                var adminUsername = _currentUserService.Username ?? "admin";
                await _activityService.LogDeleteAsync(
                    _currentUserService.UserId.Value,
                    adminUsername,
                    "Appointment",
                    id);
            }

            return NoContent();
        }
    }
}
