using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Visits.Commands;
using Stronghold.Application.Features.Visits.DTOs;
using Stronghold.Application.Features.Visits.Queries;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/visits")]
    [Authorize]
    public class VisitsController : ControllerBase
    {
        private readonly IMediator _mediator;

        public VisitsController(IMediator mediator)
        {
            _mediator = mediator;
        }

        [HttpGet("current-users-list")]
        public async Task<ActionResult<PagedResult<VisitResponse>>> GetCurrentActiveUsers([FromQuery] VisitFilter filter)
        {
            var result = await _mediator.Send(new GetCurrentVisitorsQuery { Filter = filter });
            return Ok(result);
        }

        [HttpPost("check-in")]
        public async Task<ActionResult<VisitResponse>> CheckIn([FromBody] CheckInCommand command)
        {
            var visit = await _mediator.Send(command);
            return CreatedAtAction(nameof(GetCurrentActiveUsers), new { id = visit.Id }, visit);
        }

        [HttpPost("check-out/{visitId}")]
        public async Task<ActionResult<VisitResponse>> CheckOut(int visitId)
        {
            var visit = await _mediator.Send(new CheckOutCommand { VisitId = visitId });
            return Ok(visit);
        }
    }
}
