using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Features.Auth.AdminLogin;
using Stronghold.Application.Features.Auth.Login;
using Stronghold.Application.Features.Auth.Logout;
using Stronghold.Application.Features.Auth.Register;
using Stronghold.Application.Features.Auth.RefreshToken;

namespace Stronghold.API.Controllers;

[ApiController]
public class AuthController : ControllerBase
{
    private readonly IMediator _mediator;

    public AuthController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpPost("api/auth/register")]
    public async Task<IActionResult> Register([FromBody] RegisterCommand command)
    {
        var result = await _mediator.Send(command);
        return StatusCode(201, result);
    }

    [HttpPost("api/auth/login")]
    public async Task<IActionResult> Login([FromBody] LoginCommand command)
    {
        var result = await _mediator.Send(command);
        return Ok(result);
    }

    [HttpPost("api/admin/auth/login")]
    public async Task<IActionResult> AdminLogin([FromBody] AdminLoginCommand command)
    {
        var result = await _mediator.Send(command);
        return Ok(result);
    }

    [HttpPost("api/auth/refresh-token")]
    public async Task<IActionResult> RefreshToken([FromBody] RefreshTokenCommand command)
    {
        var result = await _mediator.Send(command);
        return Ok(result);
    }

    [Authorize]
    [HttpPost("api/auth/logout")]
    public async Task<IActionResult> Logout([FromBody] LogoutCommand command)
    {
        await _mediator.Send(command);
        return NoContent();
    }
}
