using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.DependencyInjection;
using System.Security.Claims;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Request;
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

        [HttpGet("admin")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<PagedResult<AdminAppointmentResponse>>> GetAllAppointments([FromQuery] AppointmentQueryFilter filter)
        {
            return Ok(await _service.GetAllAppointmentsAsync(filter));
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

        [HttpPost("admin")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult> AdminCreate([FromBody] AdminCreateAppointmentRequest request)
        {
            var id = await _service.AdminCreateAsync(request);

            var adminUserId = GetCurrentUserId();
            if (adminUserId.HasValue)
            {
                var adminUsername = User.FindFirst(ClaimTypes.Name)?.Value ?? "admin";
                var activityService = HttpContext.RequestServices.GetService<IAdminActivityService>();
                if (activityService != null)
                {
                    await activityService.LogAddAsync(
                        adminUserId.Value,
                        adminUsername,
                        "Appointment",
                        id);
                }
            }

            return CreatedAtAction(nameof(GetAllAppointments), new { id }, new { id });
        }

        [HttpPut("admin/{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult> AdminUpdate(int id, [FromBody] AdminUpdateAppointmentRequest request)
        {
            await _service.AdminUpdateAsync(id, request);
            return NoContent();
        }

        [HttpDelete("admin/{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult> AdminDelete(int id)
        {
            await _service.AdminDeleteAsync(id);

            var adminUserId = GetCurrentUserId();
            if (adminUserId.HasValue)
            {
                var adminUsername = User.FindFirst(ClaimTypes.Name)?.Value ?? "admin";
                var activityService = HttpContext.RequestServices.GetService<IAdminActivityService>();
                if (activityService != null)
                {
                    await activityService.LogDeleteAsync(
                        adminUserId.Value,
                        adminUsername,
                        "Appointment",
                        id);
                }
            }

            return NoContent();
        }
    }
}
