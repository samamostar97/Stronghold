using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.GymVisits;
using Stronghold.Application.DTOs.Users;
using Stronghold.Application.Interfaces;
using Stronghold.Core;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/gym-visits")]
[Authorize]
public class GymVisitsController : ControllerBase
{
    private readonly IGymVisitService _gymVisitService;

    public GymVisitsController(IGymVisitService gymVisitService)
    {
        _gymVisitService = gymVisitService;
    }

    [HttpGet]
    [Authorize(Roles = Roles.Admin)]
    public async Task<ActionResult<PagedResult<GymVisitResponse>>> GetPaged([FromQuery] GymVisitSearch search)
    {
        return Ok(await _gymVisitService.GetPagedAsync(search));
    }

    /// <summary>Trenutna popunjenost teretane - vidljivo i clanovima (mobile pocetna).</summary>
    [HttpGet("occupancy")]
    public async Task<ActionResult<GymOccupancyResponse>> GetOccupancy()
    {
        return Ok(await _gymVisitService.GetOccupancyAsync());
    }

    [HttpGet("{id}")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<ActionResult<GymVisitResponse>> GetById(int id)
    {
        return Ok(await _gymVisitService.GetByIdAsync(id));
    }

    [HttpPost("check-in")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<ActionResult<GymVisitResponse>> CheckIn(CheckInRequest request)
    {
        return Ok(await _gymVisitService.CheckInAsync(request));
    }

    [HttpPut("{id}/check-out")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<ActionResult<GymVisitResponse>> CheckOut(int id)
    {
        return Ok(await _gymVisitService.CheckOutAsync(id));
    }

    [HttpGet("eligible-users")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<ActionResult<PagedResult<UserResponse>>> GetEligibleUsers([FromQuery] UserSearch search)
    {
        return Ok(await _gymVisitService.GetEligibleUsersAsync(search));
    }
}
