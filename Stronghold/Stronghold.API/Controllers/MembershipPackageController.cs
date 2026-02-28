using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.Features.AdminActivities.Commands;
using Stronghold.Application.Features.MembershipPackages.Commands;
using Stronghold.Application.Features.MembershipPackages.DTOs;
using Stronghold.Application.Features.MembershipPackages.Queries;
using Stronghold.Core.Entities;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/membership-packages")]
[Authorize]
public class MembershipPackageController : ControllerBase
{
    private readonly IMediator _mediator;

    public MembershipPackageController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<MembershipPackageResponse>>> GetAllPagedAsync([FromQuery] MembershipPackageFilter filter)
    {
        var result = await _mediator.Send(new GetPagedMembershipPackagesQuery { Filter = filter });
        return Ok(result);
    }

    [HttpGet("all")]
    public async Task<ActionResult<IEnumerable<MembershipPackageResponse>>> GetAllAsync([FromQuery] MembershipPackageFilter filter)
    {
        var result = await _mediator.Send(new GetMembershipPackagesQuery { Filter = filter });
        return Ok(result);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<MembershipPackageResponse>> GetById(int id)
    {
        var result = await _mediator.Send(new GetMembershipPackageByIdQuery { Id = id });
        return Ok(result);
    }

    [HttpPost]
    public async Task<ActionResult<MembershipPackageResponse>> Create([FromBody] CreateMembershipPackageCommand command)
    {
        var result = await _mediator.Send(command);
        await _mediator.Send(new LogAdminActivityCommand
        {
            Action = AdminActivityLogAction.Add,
            EntityType = nameof(MembershipPackage),
            EntityId = result.Id
        });
        return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<MembershipPackageResponse>> Update(int id, [FromBody] UpdateMembershipPackageCommand command)
    {
        command.Id = id;
        var result = await _mediator.Send(command);
        return Ok(result);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        await _mediator.Send(new DeleteMembershipPackageCommand { Id = id });
        await _mediator.Send(new LogAdminActivityCommand
        {
            Action = AdminActivityLogAction.Delete,
            EntityType = nameof(MembershipPackage),
            EntityId = id
        });
        return NoContent();
    }
}
