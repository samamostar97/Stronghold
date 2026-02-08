using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Filters;
using Stronghold.Application.IServices;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/appointments")]
    [Authorize]
    public class AppointmentController : UserControllerBase
    {
        private readonly IAppointmentService _service;

        public AppointmentController(IAppointmentService service)
        {
            _service = service;
        }

        [HttpGet("my")]
        public async Task<ActionResult<PagedResult<AppointmentResponse>>> GetMyAppointments([FromQuery] AppointmentQueryFilter filter)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            return Ok(await _service.GetAppointmentsByUserIdAsync(userId.Value, filter));
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult> Cancel(int id)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            await _service.CancelAppointmentAsync(userId.Value, id);
            return NoContent();
        }
    }
}
