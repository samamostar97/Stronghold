using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.IServices;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/address")]
[Authorize]
public class AddressController : UserControllerBase
{
    private readonly IAddressService _service;

    public AddressController(IAddressService service)
    {
        _service = service;
    }

    [HttpGet("my")]
    public async Task<ActionResult<AddressResponse>> GetMyAddress()
    {
        var userId = GetCurrentUserId();
        if (userId == null) return Unauthorized();

        var result = await _service.GetByUserIdAsync(userId.Value);
        if (result == null) return NotFound();

        return Ok(result);
    }

    [HttpPut("my")]
    public async Task<ActionResult<AddressResponse>> UpsertMyAddress([FromBody] UpsertAddressRequest request)
    {
        var userId = GetCurrentUserId();
        if (userId == null) return Unauthorized();

        var result = await _service.UpsertAsync(userId.Value, request);
        return Ok(result);
    }
}
