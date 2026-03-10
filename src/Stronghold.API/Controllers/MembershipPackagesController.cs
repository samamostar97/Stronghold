using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Features.MembershipPackages.CreateMembershipPackage;
using Stronghold.Application.Features.MembershipPackages.DeleteMembershipPackage;
using Stronghold.Application.Features.MembershipPackages.GetMembershipPackageById;
using Stronghold.Application.Features.MembershipPackages.GetMembershipPackages;
using Stronghold.Application.Features.MembershipPackages.UpdateMembershipPackage;

namespace Stronghold.API.Controllers;

[ApiController]
[Authorize]
[Route("api/membership-packages")]
public class MembershipPackagesController : ControllerBase
{
    private readonly IMediator _mediator;

    public MembershipPackagesController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<IActionResult> GetMembershipPackages([FromQuery] GetMembershipPackagesQuery query)
    {
        var result = await _mediator.Send(query);
        return Ok(result);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetMembershipPackageById(int id)
    {
        var result = await _mediator.Send(new GetMembershipPackageByIdQuery { Id = id });
        return Ok(result);
    }

    [HttpPost]
    public async Task<IActionResult> CreateMembershipPackage([FromBody] CreateMembershipPackageCommand command)
    {
        var result = await _mediator.Send(command);
        return StatusCode(201, result);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> UpdateMembershipPackage(int id, [FromBody] UpdateMembershipPackageCommand command)
    {
        command.Id = id;
        var result = await _mediator.Send(command);
        return Ok(result);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> DeleteMembershipPackage(int id)
    {
        await _mediator.Send(new DeleteMembershipPackageCommand { Id = id });
        return NoContent();
    }
}
