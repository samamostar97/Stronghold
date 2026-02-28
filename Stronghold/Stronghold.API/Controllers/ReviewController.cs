using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.Features.AdminActivities.Commands;
using Stronghold.Application.Features.Reviews.Commands;
using Stronghold.Application.Features.Reviews.DTOs;
using Stronghold.Application.Features.Reviews.Queries;
using Stronghold.Core.Entities;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/reviews")]
[Authorize]
public class ReviewController : ControllerBase
{
    private readonly IMediator _mediator;

    public ReviewController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet("my")]
    public async Task<ActionResult<PagedResult<UserReviewResponse>>> GetMyReviews([FromQuery] ReviewFilter filter)
    {
        var result = await _mediator.Send(new GetMyReviewsQuery { Filter = filter });
        return Ok(result);
    }

    [HttpGet("available-supplements")]
    public async Task<ActionResult<PagedResult<PurchasedSupplementResponse>>> GetAvailableSupplements([FromQuery] ReviewFilter filter)
    {
        var result = await _mediator.Send(new GetAvailableSupplementsForReviewQuery { Filter = filter });
        return Ok(result);
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<ReviewResponse>>> GetAllPagedAsync([FromQuery] ReviewFilter filter)
    {
        var result = await _mediator.Send(new GetPagedReviewsQuery { Filter = filter });
        return Ok(result);
    }

    [HttpGet("all")]
    public async Task<ActionResult<IEnumerable<ReviewResponse>>> GetAllAsync([FromQuery] ReviewFilter filter)
    {
        var result = await _mediator.Send(new GetReviewsQuery { Filter = filter });
        return Ok(result);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<ReviewResponse>> GetById(int id)
    {
        var result = await _mediator.Send(new GetReviewByIdQuery { Id = id });
        return Ok(result);
    }

    [HttpPost]
    public async Task<ActionResult<ReviewResponse>> Create([FromBody] CreateReviewCommand command)
    {
        var result = await _mediator.Send(command);
        return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<ReviewResponse>> Update(int id, [FromBody] UpdateReviewCommand command)
    {
        command.Id = id;
        var result = await _mediator.Send(command);
        return Ok(result);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        await _mediator.Send(new DeleteReviewCommand { Id = id });
        await _mediator.Send(new LogAdminActivityCommand
        {
            Action = AdminActivityLogAction.Delete,
            EntityType = nameof(Review),
            EntityId = id
        });

        return NoContent();
    }
}
