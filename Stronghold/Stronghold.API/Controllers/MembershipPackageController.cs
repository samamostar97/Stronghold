using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.Features.MembershipPackages.Commands;
using Stronghold.Application.Features.MembershipPackages.DTOs;
using Stronghold.Application.Features.MembershipPackages.Queries;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/membership-packages")]
[Authorize]
public class MembershipPackageController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly IAdminActivityService _activityService;
    private readonly ICurrentUserService _currentUserService;

    public MembershipPackageController(
        IMediator mediator,
        IAdminActivityService activityService,
        ICurrentUserService currentUserService)
    {
        _mediator = mediator;
        _activityService = activityService;
        _currentUserService = currentUserService;
    }

    [HttpGet("GetAllPaged")]
    public async Task<ActionResult<PagedResult<MembershipPackageResponse>>> GetAllPagedAsync([FromQuery] MembershipPackageFilter filter)
    {
        var result = await _mediator.Send(new GetPagedMembershipPackagesQuery { Filter = filter });
        return Ok(result);
    }

    [HttpGet("GetAll")]
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
        await LogAddActivityAsync(result.Id);
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
        await LogDeleteActivityAsync(id);
        return NoContent();
    }

    private async Task LogAddActivityAsync(int id)
    {
        if (!_currentUserService.UserId.HasValue)
        {
            return;
        }

        var adminUsername = _currentUserService.Username ?? "admin";
        await _activityService.LogAddAsync(_currentUserService.UserId.Value, adminUsername, nameof(MembershipPackage), id);
    }

    private async Task LogDeleteActivityAsync(int id)
    {
        if (!_currentUserService.UserId.HasValue)
        {
            return;
        }

        var adminUsername = _currentUserService.Username ?? "admin";
        await _activityService.LogDeleteAsync(_currentUserService.UserId.Value, adminUsername, nameof(MembershipPackage), id);
    }
}
