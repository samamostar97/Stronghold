using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Features.UserMemberships.GetActiveMemberships;
using Stronghold.Application.Features.UserMemberships.GetInactiveMemberships;
using Stronghold.Application.Features.UserMemberships.GetMembershipPayments;

namespace Stronghold.API.Controllers;

[ApiController]
[Authorize]
[Route("api/memberships")]
public class MembershipsController : ControllerBase
{
    private readonly IMediator _mediator;

    public MembershipsController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet("payments")]
    public async Task<IActionResult> GetMembershipPayments([FromQuery] GetMembershipPaymentsQuery query)
    {
        var result = await _mediator.Send(query);
        return Ok(result);
    }

    [HttpGet("active")]
    public async Task<IActionResult> GetActiveMemberships([FromQuery] GetActiveMembershipsQuery query)
    {
        var result = await _mediator.Send(query);
        return Ok(result);
    }

    [HttpGet("history")]
    public async Task<IActionResult> GetInactiveMemberships([FromQuery] GetInactiveMembershipsQuery query)
    {
        var result = await _mediator.Send(query);
        return Ok(result);
    }
}
