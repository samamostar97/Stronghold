using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.AdminVisitsDTO;
using Stronghold.Application.IServices;
using Stronghold.Infrastructure.Services;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/admin/gym-visits")]
    [Authorize(Roles = "Admin")]
    public class AdminVisitsController : ControllerBase
    {
        private readonly IGymVisitsService _visitsService;

        public AdminVisitsController(IGymVisitsService visitService)
        {
            _visitsService = visitService;
        }
        [HttpGet("current")]
        public async Task<ActionResult<IEnumerable<CurrentVisitorDTO>>> GetCurrentVisitors() 
        {
            var visitors= await _visitsService.GetCurrentVisitorsAsync();
            return Ok(visitors);
        }
        [HttpPost("check-in")]
        public async Task<ActionResult<CurrentVisitorDTO>> CheckInUser(AdminCheckInDTO checkIn)
        {
            var visitor =  await _visitsService.CheckInAsync(checkIn);
            return CreatedAtAction(nameof(GetCurrentVisitors), visitor);

        }
        // POST /api/admin/gym-visits/{visitId}/check-out
        [HttpPost("{visitId}/check-out")]
        public async Task<ActionResult> CheckOut(int visitId)
        {
            await _visitsService.CheckOutAsync(visitId);
            return NoContent();  // 204 - success, no content to return
        }
    }
}
