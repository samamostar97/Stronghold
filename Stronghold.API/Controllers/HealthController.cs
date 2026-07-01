using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/health")]
public class HealthController : ControllerBase
{
    // Anoniman jer ga koriste docker healthcheck i klijenti prije prijave;
    // ne vraca nikakve korisnicke podatke.
    [HttpGet]
    [AllowAnonymous]
    public IActionResult Get()
    {
        return Ok(new { status = "ok" });
    }
}
