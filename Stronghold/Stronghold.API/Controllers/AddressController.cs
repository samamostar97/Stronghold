using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Features.Addresses.Commands;
using Stronghold.Application.Features.Addresses.DTOs;
using Stronghold.Application.Features.Addresses.Queries;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/address")]
[Authorize]
public class AddressController : ControllerBase
{
    private readonly IMediator _mediator;

    public AddressController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet("my")]
    public async Task<ActionResult<AddressResponse>> GetMyAddress()
    {
        var result = await _mediator.Send(new GetMyAddressQuery());
        if (result == null) return NotFound();

        return Ok(result);
    }

    [HttpGet("{userId:int}")]
    public async Task<ActionResult<AddressResponse>> GetUserAddress(int userId)
    {
        var result = await _mediator.Send(new GetUserAddressQuery { UserId = userId });
        if (result == null) return NotFound();

        return Ok(result);
    }

    [HttpPut("my")]
    public async Task<ActionResult<AddressResponse>> UpsertMyAddress([FromBody] UpsertMyAddressCommand command)
    {
        var result = await _mediator.Send(command);
        return Ok(result);
    }
}
