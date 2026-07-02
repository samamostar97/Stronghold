using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Memberships;
using Stronghold.Application.Interfaces;
using Stronghold.Core;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/memberships")]
[Authorize(Roles = Roles.Admin)]
public class MembershipsController : ControllerBase
{
    private readonly IMembershipService _membershipService;

    public MembershipsController(IMembershipService membershipService)
    {
        _membershipService = membershipService;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<MembershipResponse>>> GetPaged([FromQuery] MembershipSearch search)
    {
        return Ok(await _membershipService.GetPagedAsync(search));
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<MembershipResponse>> GetById(int id)
    {
        return Ok(await _membershipService.GetByIdAsync(id));
    }

    /// <summary>Dodjela clanarine = evidencija uplate (aktivira ili produzava clanarinu).</summary>
    [HttpPost]
    public async Task<ActionResult<MembershipResponse>> Assign(MembershipAssignRequest request)
    {
        return Ok(await _membershipService.AssignAsync(request));
    }

    [HttpPut("{id}/revoke")]
    public async Task<ActionResult<MembershipResponse>> Revoke(int id, MembershipRevokeRequest request)
    {
        return Ok(await _membershipService.RevokeAsync(id, request));
    }
}
