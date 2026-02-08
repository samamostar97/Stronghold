using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Filters;
using Stronghold.Application.IServices;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/visits")]
    [Authorize(Roles = "Admin")]
    public class VisitsController : ControllerBase
    {
        private readonly IVisitService _visitService;

        public VisitsController(IVisitService visitService)
        {
            _visitService = visitService;
        }

        [HttpGet("current-users-list")]
        public async Task<ActionResult<PagedResult<VisitResponse>>> GetCurrentActiveUsers([FromQuery] VisitQueryFilter filter)
        {
            var result = await _visitService.GetCurrentVisitorsAsync(filter);
            return Ok(result);
        }

        [HttpPost("check-in")]
        public async Task<ActionResult<VisitResponse>> CheckIn([FromBody] CheckInRequest request)
        {
            var visit = await _visitService.CheckInAsync(request);
            return CreatedAtAction(nameof(GetCurrentActiveUsers), new { id = visit.Id }, visit);
        }

        [HttpPost("check-out/{visitId}")]
        public async Task<ActionResult<VisitResponse>> CheckOut(int visitId)
        {
            var visit = await _visitService.CheckOutAsync(visitId);
            return Ok(visit);
        }
    }
}
