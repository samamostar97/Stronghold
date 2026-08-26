using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/health")]
public class HealthController : ControllerBase
{
    // Anoniman - koriste ga docker healthcheck i klijenti prije prijave.
    [HttpGet]
    [AllowAnonymous]
    public IActionResult Get()
    {
        return Ok(new { status = "ok" });
    }
}
