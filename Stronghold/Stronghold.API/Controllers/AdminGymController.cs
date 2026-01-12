using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.GymVisits;

[ApiController]
[Route("api/admin/gym")]
[Authorize(Roles = "Admin")]
public class AdminGymController : ControllerBase
{
    private readonly IGymVisitService _service;

    public AdminGymController(IGymVisitService service)
    {
        _service = service;
    }

    // Admin clicks "Check in" in UI
    [HttpPost("check-in/{userId:int}")]
    public async Task<IActionResult> CheckIn(int userId)
    {
        try
        {
            await _service.CheckInAsync(userId);
            return Ok();
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ex.Message);
        }
    }

    // Admin sees who is inside
    [HttpGet("currently-inside")]
    public async Task<IActionResult> CurrentlyInside()
        => Ok(await _service.GetCurrentlyInGymAsync());
}
