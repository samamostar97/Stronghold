using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.AdminUsersDTO;
using Stronghold.Application.IServices;
using Stronghold.Infrastructure.Services;
using System.Security.Claims;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/admin/users")]
[Authorize(Roles = "Admin")]
public class AdminUsersController : ControllerBase
{
    private readonly IAdminUserService _service;

    public AdminUsersController(IAdminUserService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<AdminUserTableRowDTO>>> GetUsers(
    [FromQuery] string? search,
    [FromQuery] int pageNumber = 1,
    [FromQuery] int pageSize = 10)
    {
        var pagination = new PaginationRequest { PageNumber = pageNumber, PageSize = pageSize };
        var result = await _service.GetUsersAsync(search, pagination);
        return Ok(result);
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<AdminUserDetailsDTO>> GetById(int id)
    {
        var user = await _service.GetByIdAsync(id);
        if (user == null) return NotFound();
        return Ok(user);
    }

    [HttpPost]
    public async Task<ActionResult> Create([FromBody] AdminCreateUserDTO dto)
    {
        var id = await _service.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id }, new { id });
    }

    [HttpPut("{id:int}")]
    public async Task<ActionResult> Update(int id, [FromBody] AdminUpdateUserDTO dto)
    {
        var ok = await _service.UpdateAsync(id, dto);
        if (!ok) return NotFound();
        return NoContent();
    }

    [HttpDelete("{id:int}")]
    public async Task<ActionResult> SoftDelete(int id)
    {
        var adminId = GetCurrentUserId();
        var ok = await _service.SoftDeleteAsync(id, adminId);
        if (!ok) return NotFound();
        return NoContent();
    }

    [HttpPost("{id:int}/restore")]
    public async Task<ActionResult> Restore(int id)
    {
        var ok = await _service.RestoreAsync(id);
        if (!ok) return NotFound();
        return NoContent();
    }

    private int GetCurrentUserId()
    {
        var value = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return int.TryParse(value, out var id) ? id : 0;
    }
}