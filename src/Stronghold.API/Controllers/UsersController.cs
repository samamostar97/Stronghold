using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Features.Users.CreateUser;
using Stronghold.Application.Features.Users.DeleteUser;
using Stronghold.Application.Features.Users.GetUserById;
using Stronghold.Application.Features.Users.GetUsers;
using Stronghold.Application.Features.Users.GetMyProfile;
using Stronghold.Application.Features.Users.UpdateMyProfile;
using Stronghold.Application.Features.Users.UpdateProfileImage;
using Stronghold.Application.Features.Users.UpdateUser;
using Stronghold.Application.Features.UserMemberships.AssignMembership;
using Stronghold.Application.Features.UserMemberships.CancelMembership;
using Stronghold.Application.Features.UserMemberships.GetUserMembership;
using Stronghold.Application.Features.UserMemberships.GetMembershipHistory;
using Stronghold.Application.Features.Orders.GetUserOrders;
using Stronghold.Application.Features.Appointments.GetUserAppointments;
using Stronghold.Application.Features.Reviews.GetUserReviews;

namespace Stronghold.API.Controllers;

[ApiController]
[Authorize]
[Route("api/users")]
public class UsersController : ControllerBase
{
    private readonly IMediator _mediator;

    public UsersController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<IActionResult> GetUsers([FromQuery] GetUsersQuery query)
    {
        var result = await _mediator.Send(query);
        return Ok(result);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetUserById(int id)
    {
        var result = await _mediator.Send(new GetUserByIdQuery { Id = id });
        return Ok(result);
    }

    [HttpPost]
    public async Task<IActionResult> CreateUser([FromBody] CreateUserCommand command)
    {
        var result = await _mediator.Send(command);
        return StatusCode(201, result);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> UpdateUser(int id, [FromBody] UpdateUserCommand command)
    {
        command.Id = id;
        var result = await _mediator.Send(command);
        return Ok(result);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> DeleteUser(int id)
    {
        await _mediator.Send(new DeleteUserCommand { Id = id });
        return NoContent();
    }

    [HttpGet("me")]
    public async Task<IActionResult> GetMyProfile()
    {
        var result = await _mediator.Send(new GetMyProfileQuery());
        return Ok(result);
    }

    [HttpPut("me")]
    public async Task<IActionResult> UpdateMyProfile([FromBody] UpdateMyProfileCommand command)
    {
        var result = await _mediator.Send(command);
        return Ok(result);
    }

    [HttpPut("me/profile-image")]
    public async Task<IActionResult> UpdateProfileImage(IFormFile file)
    {
        var command = new UpdateProfileImageCommand
        {
            FileStream = file.OpenReadStream(),
            FileName = file.FileName
        };

        var result = await _mediator.Send(command);
        return Ok(result);
    }

    [HttpPost("{id:int}/membership")]
    public async Task<IActionResult> AssignMembership(int id, [FromBody] AssignMembershipCommand command)
    {
        command.UserId = id;
        var result = await _mediator.Send(command);
        return StatusCode(201, result);
    }

    [HttpDelete("{id:int}/membership")]
    public async Task<IActionResult> CancelMembership(int id)
    {
        await _mediator.Send(new CancelMembershipCommand { UserId = id });
        return NoContent();
    }

    [HttpGet("{id:int}/membership")]
    public async Task<IActionResult> GetUserMembership(int id)
    {
        var result = await _mediator.Send(new GetUserMembershipQuery { UserId = id });
        return Ok(result);
    }

    [HttpGet("{id:int}/membership-history")]
    public async Task<IActionResult> GetMembershipHistory(int id, [FromQuery] GetMembershipHistoryQuery query)
    {
        query.UserId = id;
        var result = await _mediator.Send(query);
        return Ok(result);
    }

    [HttpGet("{id:int}/orders")]
    public async Task<IActionResult> GetUserOrders(int id, [FromQuery] GetUserOrdersQuery query)
    {
        query.UserId = id;
        var result = await _mediator.Send(query);
        return Ok(result);
    }

    [HttpGet("{id:int}/appointments")]
    public async Task<IActionResult> GetUserAppointments(int id, [FromQuery] GetUserAppointmentsQuery query)
    {
        query.UserId = id;
        var result = await _mediator.Send(query);
        return Ok(result);
    }

    [HttpGet("{id:int}/reviews")]
    public async Task<IActionResult> GetUserReviews(int id, [FromQuery] GetUserReviewsQuery query)
    {
        query.UserId = id;
        var result = await _mediator.Send(query);
        return Ok(result);
    }
}
