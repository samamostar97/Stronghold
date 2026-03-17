using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Features.Seminars.CreateSeminar;
using Stronghold.Application.Features.Seminars.DeleteSeminar;
using Stronghold.Application.Features.Seminars.GetSeminar;
using Stronghold.Application.Features.Seminars.GetSeminarRegistrations;
using Stronghold.Application.Features.Seminars.GetSeminars;
using Stronghold.Application.Features.Seminars.GetMySeminars;
using Stronghold.Application.Features.Seminars.RegisterForSeminar;
using Stronghold.Application.Features.Seminars.UpdateSeminar;

namespace Stronghold.API.Controllers;

[ApiController]
[Authorize]
[Route("api/seminars")]
public class SeminarsController : ControllerBase
{
    private readonly IMediator _mediator;

    public SeminarsController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<IActionResult> GetSeminars([FromQuery] GetSeminarsQuery query)
    {
        var result = await _mediator.Send(query);
        return Ok(result);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetSeminar(int id)
    {
        var result = await _mediator.Send(new GetSeminarQuery { Id = id });
        return Ok(result);
    }

    [HttpPost]
    public async Task<IActionResult> CreateSeminar([FromBody] CreateSeminarCommand command)
    {
        var result = await _mediator.Send(command);
        return StatusCode(201, result);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> UpdateSeminar(int id, [FromBody] UpdateSeminarCommand command)
    {
        command.Id = id;
        var result = await _mediator.Send(command);
        return Ok(result);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> DeleteSeminar(int id)
    {
        await _mediator.Send(new DeleteSeminarCommand { Id = id });
        return NoContent();
    }

    [HttpGet("{id:int}/registrations")]
    public async Task<IActionResult> GetRegistrations(int id)
    {
        var result = await _mediator.Send(new GetSeminarRegistrationsQuery { SeminarId = id });
        return Ok(result);
    }

    [HttpPost("{id:int}/register")]
    public async Task<IActionResult> Register(int id)
    {
        await _mediator.Send(new RegisterForSeminarCommand { SeminarId = id });
        return NoContent();
    }

    [HttpGet("my")]
    public async Task<IActionResult> GetMySeminars()
    {
        var result = await _mediator.Send(new GetMySeminarsQuery());
        return Ok(result);
    }
}
