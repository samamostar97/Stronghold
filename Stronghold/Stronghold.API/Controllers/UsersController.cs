using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.Features.AdminActivities.Commands;
using Stronghold.Application.Features.Users.Commands;
using Stronghold.Application.Features.Users.DTOs;
using Stronghold.Application.Features.Users.Queries;
using Stronghold.Core.Entities;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/users")]
[Authorize]
public class UsersController : ControllerBase
{
    private readonly IMediator _mediator;

    public UsersController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<UserResponse>>> GetAllPagedAsync([FromQuery] UserFilter filter)
    {
        var result = await _mediator.Send(new GetPagedUsersQuery { Filter = filter });
        return Ok(result);
    }

    [HttpGet("all")]
    public async Task<ActionResult<IReadOnlyList<UserResponse>>> GetAllAsync([FromQuery] UserFilter filter)
    {
        var result = await _mediator.Send(new GetUsersQuery { Filter = filter });
        return Ok(result);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<UserResponse>> GetById(int id)
    {
        var result = await _mediator.Send(new GetUserByIdQuery { Id = id });
        return Ok(result);
    }

    [HttpPost]
    public async Task<ActionResult<UserResponse>> Create([FromBody] CreateUserCommand command)
    {
        var result = await _mediator.Send(command);
        await _mediator.Send(new LogAdminActivityCommand
        {
            Action = AdminActivityLogAction.Add,
            EntityType = nameof(User),
            EntityId = result.Id
        });
        return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<UserResponse>> Update(int id, [FromBody] UpdateUserCommand command)
    {
        command.Id = id;
        var result = await _mediator.Send(command);
        return Ok(result);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        await _mediator.Send(new DeleteUserCommand { Id = id });
        await _mediator.Send(new LogAdminActivityCommand
        {
            Action = AdminActivityLogAction.Delete,
            EntityType = nameof(User),
            EntityId = id
        });
        return NoContent();
    }

    [HttpPost("{id}/image")]
    public async Task<ActionResult<UserResponse>> UploadImage(int id, IFormFile file)
    {
        if (file == null || file.Length == 0)
        {
            return BadRequest("Nije odabrana slika");
        }

        await using var stream = file.OpenReadStream();
        var fileRequest = new FileUploadRequest
        {
            FileStream = stream,
            FileName = file.FileName,
            ContentType = file.ContentType,
            FileSize = file.Length
        };

        var result = await _mediator.Send(new UploadUserImageCommand
        {
            Id = id,
            FileRequest = fileRequest
        });

        return Ok(result);
    }

    [HttpDelete("{id}/image")]
    public async Task<IActionResult> DeleteImage(int id)
    {
        await _mediator.Send(new DeleteUserImageCommand { Id = id });
        return NoContent();
    }

}
