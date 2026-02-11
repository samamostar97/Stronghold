using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.IServices;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    [AllowAnonymous]
    [HttpPost("login")]
    public async Task<ActionResult<AuthResponse>> Login([FromBody] LoginRequest request)
    {
        var response = await _authService.LoginAsync(request);
        return Ok(response);
    }

    [AllowAnonymous]
    [HttpPost("login/admin")]
    public async Task<ActionResult<AuthResponse>> AdminLogin([FromBody] LoginRequest request)
    {
        var response = await _authService.LoginAsync(request);
        if (response.Role != "Admin")
            return StatusCode(403, new { error = "Pristup odbijen. Samo administratori mogu pristupiti." });
        return Ok(response);
    }

    [AllowAnonymous]
    [HttpPost("login/member")]
    public async Task<ActionResult<AuthResponse>> MemberLogin([FromBody] LoginRequest request)
    {
        var response = await _authService.LoginAsync(request);
        if (response.Role == "Admin")
            return StatusCode(403, new { error = "Administratori koriste desktop aplikaciju." });
        return Ok(response);
    }

    [AllowAnonymous]
    [HttpPost("register")]
    public async Task<ActionResult<AuthResponse>> Register([FromBody] RegisterRequest request)
    {
        var response = await _authService.RegisterAsync(request);

        return CreatedAtAction(nameof(Login), response);
    }

    [AllowAnonymous]
    [HttpPost("forgot-password")]
    public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordRequest request)
    {
        await _authService.ForgotPasswordAsync(request);
        return Ok(new { message = "Ako nalog sa ovim emailom postoji, kod za reset je poslan." });
    }

    [AllowAnonymous]
    [HttpPost("reset-password")]
    public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequest request)
    {
        await _authService.ResetPasswordAsync(request);
        return Ok(new { message = "Lozinka uspješno resetovana" });
    }

    [Authorize]
    [HttpPut("change-password")]
    public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request)
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
            return Unauthorized(new { message = "Nevalidan token" });

        await _authService.ChangePasswordAsync(userId, request);
        return Ok(new { message = "Lozinka uspješno promijenjena" });
    }
}
