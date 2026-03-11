using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Features.GymVisits.CheckIn;
using Stronghold.Application.Features.GymVisits.CheckOut;
using Stronghold.Application.Features.GymVisits.GetActiveGymVisits;
using Stronghold.Application.Features.GymVisits.GetEligibleForCheckIn;
using Stronghold.Application.Features.GymVisits.GetGymVisits;

namespace Stronghold.API.Controllers;

[ApiController]
[Authorize]
[Route("api/gym-visits")]
public class GymVisitsController : ControllerBase
{
    private readonly IMediator _mediator;

    public GymVisitsController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpPost("check-in")]
    public async Task<IActionResult> CheckIn([FromBody] CheckInCommand command)
    {
        var result = await _mediator.Send(command);
        return StatusCode(201, result);
    }

    [HttpPost("{id:int}/check-out")]
    public async Task<IActionResult> CheckOut(int id)
    {
        var result = await _mediator.Send(new CheckOutCommand { Id = id });
        return Ok(result);
    }

    [HttpGet("active")]
    public async Task<IActionResult> GetActiveGymVisits()
    {
        var result = await _mediator.Send(new GetActiveGymVisitsQuery());
        return Ok(result);
    }

    [HttpGet]
    public async Task<IActionResult> GetGymVisits([FromQuery] GetGymVisitsQuery query)
    {
        var result = await _mediator.Send(query);
        return Ok(result);
    }

    [HttpGet("eligible-members")]
    public async Task<IActionResult> GetEligibleForCheckIn([FromQuery] GetEligibleForCheckInQuery query)
    {
        var result = await _mediator.Send(query);
        return Ok(result);
    }
}
