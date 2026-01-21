using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.AdminVisitsDTO;
using Stronghold.Application.Filters;
using Stronghold.Application.IServices;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/admin/visits")]
    [Authorize(Roles = "Admin")]
    public class AdminVisitsController : ControllerBase
    {
        private readonly IAdminVisitService _visitService;

        public AdminVisitsController(IAdminVisitService visitService)
        {
            _visitService = visitService;
        }

        [HttpGet("current-users-list")]
        public async Task<ActionResult<IEnumerable<VisitDTO>>> GetCurrentActiveUsers()
        {
            var users = await _visitService.GetCurrentVisitorsAsync();
            return Ok(users);
        }

        [HttpPost("check-in")]
        public async Task<ActionResult<VisitDTO>> CheckIn([FromBody] CheckInRequestDTO request)
        {
            var visit = await _visitService.CheckInAsync(request);
            return CreatedAtAction(nameof(GetCurrentActiveUsers), new { id = visit.Id }, visit);
        }

        [HttpPost("check-out/{visitId}")]
        public async Task<ActionResult<VisitDTO>> CheckOut(int visitId)
        {
            var visit = await _visitService.CheckOutAsync(visitId);
            return Ok(visit);
        }
    }
}
