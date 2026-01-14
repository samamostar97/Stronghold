using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.AdminMembershipsDTO;
using Stronghold.Application.IServices;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/admin/memberships")]
[Authorize(Roles = "Admin")]
public class AdminMembershipController : ControllerBase
{
    private readonly IAdminMembershipService _service;

    public AdminMembershipController(IAdminMembershipService service)
    {
        _service = service;
    }

    #region Membership Packages

    [HttpGet("packages")]
    public async Task<ActionResult<List<MembershipPackageDTO>>> GetAllPackages()
    {
        var result = await _service.GetAllPackagesAsync();
        return Ok(result);
    }

    [HttpGet("packages/{packageId:int}")]
    public async Task<ActionResult<MembershipPackageDTO>> GetPackageById(int packageId)
    {
        var result = await _service.GetPackageByIdAsync(packageId);
        if (result == null) return NotFound();
        return Ok(result);
    }

    [HttpPost("packages")]
    public async Task<ActionResult<MembershipPackageDTO>> CreatePackage([FromBody] CreateMembershipPackageRequest request)
    {
        var result = await _service.CreatePackageAsync(request);
        return CreatedAtAction(nameof(GetPackageById), new { packageId = result.Id }, result);
    }

    [HttpPut("packages/{packageId:int}")]
    public async Task<ActionResult<MembershipPackageDTO>> UpdatePackage(int packageId, [FromBody] UpdateMembershipPackageRequest request)
    {
        var result = await _service.UpdatePackageAsync(packageId, request);
        if (result == null) return NotFound();
        return Ok(result);
    }

    [HttpDelete("packages/{packageId:int}")]
    public async Task<IActionResult> DeletePackage(int packageId)
    {
        var ok = await _service.DeletePackageAsync(packageId);
        if (!ok) return NotFound();
        return NoContent();
    }

    #endregion

    #region Users

    [HttpGet("users")]
    public async Task<ActionResult<PagedResult<MembershipUserRowDTO>>> GetUsers(
        [FromQuery] string? search,
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 10)
    {
        var pagination = new PaginationRequest { PageNumber = pageNumber, PageSize = pageSize };
        var result = await _service.GetUsersAsync(search, pagination);
        return Ok(result);
    }

    [HttpGet("users/{userId:int}/membership")]
    public async Task<ActionResult<UserMembershipDTO>> GetUserMembership(int userId)
    {
        var result = await _service.GetUserMembershipAsync(userId);
        if (result == null) return NotFound();
        return Ok(result);
    }

    #endregion

    #region Payment History

    [HttpGet("users/{userId:int}/payments")]
    public async Task<ActionResult<PagedResult<MembershipPaymentRowDTO>>> GetPayments(
        int userId,
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 20)
    {
        var pagination = new PaginationRequest { PageNumber = pageNumber, PageSize = pageSize };
        var result = await _service.GetPaymentsAsync(userId, pagination);
        return Ok(result);
    }

    #endregion

    #region Assign Membership

    [HttpPost("users/{userId:int}/assign")]
    public async Task<IActionResult> AssignMembership(int userId, [FromBody] AddMembershipPaymentRequest request)
    {
        var ok = await _service.AssignMembershipAsync(userId, request);
        if (!ok) return NotFound();
        return NoContent();
    }

    #endregion
}
