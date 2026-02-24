using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Supplements.Commands;
using Stronghold.Application.Features.Supplements.DTOs;
using Stronghold.Application.Features.Supplements.Queries;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/supplements")]
[Authorize]
public class SupplementController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly IAdminActivityService _activityService;
    private readonly ICurrentUserService _currentUserService;

    public SupplementController(
        IMediator mediator,
        IAdminActivityService activityService,
        ICurrentUserService currentUserService)
    {
        _mediator = mediator;
        _activityService = activityService;
        _currentUserService = currentUserService;
    }

    [HttpGet("GetAllPaged")]
    public async Task<ActionResult<PagedResult<SupplementResponse>>> GetAllPagedAsync([FromQuery] SupplementFilter filter)
    {
        var result = await _mediator.Send(new GetPagedSupplementsQuery { Filter = filter });
        return Ok(result);
    }

    [HttpGet("GetAll")]
    public async Task<ActionResult<IEnumerable<SupplementResponse>>> GetAllAsync([FromQuery] SupplementFilter filter)
    {
        var result = await _mediator.Send(new GetSupplementsQuery { Filter = filter });
        return Ok(result);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<SupplementResponse>> GetById(int id)
    {
        var result = await _mediator.Send(new GetSupplementByIdQuery { Id = id });
        return Ok(result);
    }

    [HttpPost]
    public async Task<ActionResult<SupplementResponse>> Create([FromBody] CreateSupplementCommand command)
    {
        var result = await _mediator.Send(command);
        await LogAddActivityAsync(result.Id);
        return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<SupplementResponse>> Update(int id, [FromBody] UpdateSupplementCommand command)
    {
        command.Id = id;
        var result = await _mediator.Send(command);
        return Ok(result);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        await _mediator.Send(new DeleteSupplementCommand { Id = id });
        await LogDeleteActivityAsync(id);
        return NoContent();
    }

    [HttpPost("{id}/image")]
    public async Task<ActionResult<SupplementResponse>> UploadImage(int id, IFormFile file)
    {
        if (file == null || file.Length == 0)
        {
            return BadRequest("Nije odabrana slika.");
        }

        await using var stream = file.OpenReadStream();
        var fileRequest = new FileUploadRequest
        {
            FileStream = stream,
            FileName = file.FileName,
            ContentType = file.ContentType,
            FileSize = file.Length
        };

        var result = await _mediator.Send(new UploadSupplementImageCommand
        {
            Id = id,
            FileRequest = fileRequest
        });

        return Ok(result);
    }

    [HttpDelete("{id}/image")]
    public async Task<IActionResult> DeleteImage(int id)
    {
        await _mediator.Send(new DeleteSupplementImageCommand { Id = id });
        return NoContent();
    }

    [HttpGet("{id}/reviews")]
    public async Task<ActionResult<IEnumerable<SupplementReviewResponse>>> GetReviews(int id)
    {
        var result = await _mediator.Send(new GetSupplementReviewsQuery { SupplementId = id });
        return Ok(result);
    }

    private async Task LogAddActivityAsync(int id)
    {
        if (!_currentUserService.UserId.HasValue)
        {
            return;
        }

        var adminUsername = _currentUserService.Username ?? "admin";
        await _activityService.LogAddAsync(_currentUserService.UserId.Value, adminUsername, nameof(Supplement), id);
    }

    private async Task LogDeleteActivityAsync(int id)
    {
        if (!_currentUserService.UserId.HasValue)
        {
            return;
        }

        var adminUsername = _currentUserService.Username ?? "admin";
        await _activityService.LogDeleteAsync(_currentUserService.UserId.Value, adminUsername, nameof(Supplement), id);
    }
}
