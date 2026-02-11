using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Filters;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/seminar")]
    public class SeminarController : BaseController<Seminar, SeminarResponse, CreateSeminarRequest, UpdateSeminarRequest, SeminarQueryFilter, int>
    {
        private readonly ISeminarService _seminarService;

        public SeminarController(ISeminarService service) : base(service)
        {
            _seminarService = service;
        }

        // User endpoint
        [HttpGet("upcoming")]
        [Authorize(Roles = "GymMember")]
        public async Task<ActionResult<IEnumerable<UserSeminarResponse>>> GetUpcomingSeminarsAsync()
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();
            var result = await _seminarService.GetUpcomingSeminarsAsync(userId.Value);
            return Ok(result);
        }

        // User endpoint
        [HttpPost("{id}/attend")]
        [Authorize(Roles = "GymMember")]
        public async Task<ActionResult> AttendSeminarAsync(int id)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();
            await _seminarService.AttendSeminarAsync(userId.Value, id);
            return NoContent();
        }

        // User endpoint
        [HttpDelete("{id}/attend")]
        [Authorize(Roles = "GymMember")]
        public async Task<ActionResult> CancelAttendanceAsync(int id)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();
            await _seminarService.CancelAttendanceAsync(userId.Value, id);
            return NoContent();
        }

        [HttpPatch("{id}/cancel")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult> CancelSeminarAsync(int id)
        {
            await _seminarService.CancelSeminarAsync(id);
            return NoContent();
        }

        [Authorize(Roles = "Admin,GymMember")]
        [HttpGet("GetAll")]

        public override Task<ActionResult<IEnumerable<SeminarResponse>>> GetAllAsync([FromQuery] SeminarQueryFilter filter)
        {
            return base.GetAllAsync(filter);
        }
        [Authorize(Roles = "Admin,GymMember")]
        [HttpGet("GetAllPaged")]
        public override Task<ActionResult<PagedResult<SeminarResponse>>> GetAllPagedAsync([FromQuery] SeminarQueryFilter filter)
        {
            return base.GetAllPagedAsync(filter);
        }
        [Authorize(Roles = "Admin")]
        [HttpPost]
        public override Task<ActionResult<SeminarResponse>> Create([FromBody] CreateSeminarRequest dto)
        {
            return base.Create(dto);
        }
        [Authorize(Roles = "Admin")]
        [HttpPut("{id}")]
        public override Task<ActionResult<SeminarResponse>> Update(int id, [FromBody] UpdateSeminarRequest dto)
        {
            return base.Update(id, dto);
        }
        [Authorize(Roles = "Admin,GymMember")]
        [HttpGet("{id}")]
        public override Task<ActionResult<SeminarResponse>> GetById(int id)
        {
            return base.GetById(id);
        }
        [Authorize(Roles = "Admin")]
        [HttpDelete("{id}")]
        public override Task<IActionResult> Delete(int id)
        {
            return base.Delete(id);
        }

        [HttpGet("{id}/attendees")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<IEnumerable<SeminarAttendeeResponse>>> GetSeminarAttendees(int id)
        {
            var result = await _seminarService.GetSeminarAttendeesAsync(id);
            return Ok(result);
        }
    }
}
