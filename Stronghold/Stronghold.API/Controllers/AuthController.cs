using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Features.Auth.Commands;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IMediator _mediator;

    public AuthController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [AllowAnonymous]
    [HttpPost("login")]
    public async Task<ActionResult<AuthResponse>> Login([FromBody] LoginRequest request)
    {
        var response = await _mediator.Send(new LoginCommand
        {
            Username = request.Username,
            Password = request.Password
        });
        return Ok(response);
    }

    [AllowAnonymous]
    [HttpPost("login/admin")]
    public async Task<ActionResult<AuthResponse>> AdminLogin([FromBody] LoginRequest request)
    {
        var response = await _mediator.Send(new AdminLoginCommand
        {
            Username = request.Username,
            Password = request.Password
        });
        return Ok(response);
    }

    [AllowAnonymous]
    [HttpPost("login/member")]
    public async Task<ActionResult<AuthResponse>> MemberLogin([FromBody] LoginRequest request)
    {
        var response = await _mediator.Send(new MemberLoginCommand
        {
            Username = request.Username,
            Password = request.Password
        });
        return Ok(response);
    }

    [AllowAnonymous]
    [HttpPost("register")]
    public async Task<ActionResult<AuthResponse>> Register([FromBody] RegisterRequest request)
    {
        var response = await _mediator.Send(new RegisterCommand
        {
            FirstName = request.FirstName,
            LastName = request.LastName,
            Username = request.Username,
            Email = request.Email,
            PhoneNumber = request.PhoneNumber,
            Password = request.Password
        });

        return CreatedAtAction(nameof(Login), response);
    }

    [AllowAnonymous]
    [HttpPost("forgot-password")]
    public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordRequest request)
    {
        await _mediator.Send(new ForgotPasswordCommand { Email = request.Email });
        return Ok(new { message = "Ako nalog sa ovim emailom postoji, kod za reset je poslan." });
    }

    [AllowAnonymous]
    [HttpPost("reset-password")]
    public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequest request)
    {
        await _mediator.Send(new ResetPasswordCommand
        {
            Email = request.Email,
            Code = request.Code,
            NewPassword = request.NewPassword
        });
        return Ok(new { message = "Lozinka uspjesno resetovana" });
    }

    [Authorize]
    [HttpPut("change-password")]
    public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request)
    {
        await _mediator.Send(new ChangePasswordCommand
        {
            CurrentPassword = request.CurrentPassword,
            NewPassword = request.NewPassword
        });
        return Ok(new { message = "Lozinka uspjesno promijenjena" });
    }
}
