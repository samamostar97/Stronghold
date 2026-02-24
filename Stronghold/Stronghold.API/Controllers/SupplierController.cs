using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Suppliers.Commands;
using Stronghold.Application.Features.Suppliers.DTOs;
using Stronghold.Application.Features.Suppliers.Queries;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/suppliers")]
[Authorize]
public class SupplierController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly IAdminActivityService _activityService;
    private readonly ICurrentUserService _currentUserService;

    public SupplierController(
        IMediator mediator,
        IAdminActivityService activityService,
        ICurrentUserService currentUserService)
    {
        _mediator = mediator;
        _activityService = activityService;
        _currentUserService = currentUserService;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<SupplierResponse>>> GetAllPagedAsync([FromQuery] SupplierFilter filter)
    {
        var result = await _mediator.Send(new GetPagedSuppliersQuery { Filter = filter });
        return Ok(result);
    }

    [HttpGet("all")]
    public async Task<ActionResult<IEnumerable<SupplierResponse>>> GetAllAsync([FromQuery] SupplierFilter filter)
    {
        var result = await _mediator.Send(new GetSuppliersQuery { Filter = filter });
        return Ok(result);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<SupplierResponse>> GetById(int id)
    {
        var result = await _mediator.Send(new GetSupplierByIdQuery { Id = id });
        return Ok(result);
    }

    [HttpPost]
    public async Task<ActionResult<SupplierResponse>> Create([FromBody] CreateSupplierCommand command)
    {
        var result = await _mediator.Send(command);
        await LogAddActivityAsync(result.Id);
        return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<SupplierResponse>> Update(int id, [FromBody] UpdateSupplierCommand command)
    {
        command.Id = id;
        var result = await _mediator.Send(command);
        return Ok(result);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        await _mediator.Send(new DeleteSupplierCommand { Id = id });
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
        await _activityService.LogAddAsync(_currentUserService.UserId.Value, adminUsername, nameof(Supplier), id);
    }

    private async Task LogDeleteActivityAsync(int id)
    {
        if (!_currentUserService.UserId.HasValue)
        {
            return;
        }

        var adminUsername = _currentUserService.Username ?? "admin";
        await _activityService.LogDeleteAsync(_currentUserService.UserId.Value, adminUsername, nameof(Supplier), id);
    }
}
