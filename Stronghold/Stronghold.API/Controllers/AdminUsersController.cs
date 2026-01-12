using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.UserDTOs;
using Stronghold.Application.IServices;
using Stronghold.Application.Users;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/admin/users")]
[Authorize(Roles = "Admin")] // If you store role as enum, make sure your JWT puts "Administrator" as role claim
public class AdminUsersController : ControllerBase
{
    private readonly IUserService _userService;

    public AdminUsersController(IUserService userService)
    {
        _userService = userService;
    }

    // GET: api/admin/users?pageNumber=1&pageSize=10&search=samir
    [HttpGet]
    public async Task<IActionResult> Search([FromQuery] UserSearchRequest request)
    {
        var result = await _userService.SearchAsync(request);
        return Ok(result);
    }

    // GET: api/admin/users/5
    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        try
        {
            var user = await _userService.GetByIdAsync(id);
            return Ok(user);
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }

    // POST: api/admin/users
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] UserInsertRequest request)
    {
        try
        {
            var id = await _userService.CreateAsync(request);
            return CreatedAtAction(nameof(GetById), new { id }, new { id });
        }
        catch (InvalidOperationException ex)
        {
            // e.g. username/email already taken
            return BadRequest(new { message = ex.Message });
        }
    }

    // PUT: api/admin/users/5
    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateUserRequest request)
    {
        try
        {
            await _userService.UpdateAsync(id, request);
            return NoContent();
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { message = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    // DELETE: api/admin/users/5
    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        await _userService.DeleteAsync(id);
        return NoContent();
    }
}
