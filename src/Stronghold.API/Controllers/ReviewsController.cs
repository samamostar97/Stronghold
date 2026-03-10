using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Features.Reviews.CreateReview;
using Stronghold.Application.Features.Reviews.DeleteReview;
using Stronghold.Application.Features.Reviews.GetProductReviews;
using Stronghold.Application.Features.Reviews.GetStaffReviews;
using Stronghold.Application.Features.Reviews.UpdateReview;

namespace Stronghold.API.Controllers;

[ApiController]
[Authorize]
[Route("api/reviews")]
public class ReviewsController : ControllerBase
{
    private readonly IMediator _mediator;

    public ReviewsController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpPost]
    public async Task<IActionResult> CreateReview([FromBody] CreateReviewCommand command)
    {
        var result = await _mediator.Send(command);
        return StatusCode(201, result);
    }

    [HttpGet("products/{productId:int}")]
    public async Task<IActionResult> GetProductReviews(int productId, [FromQuery] GetProductReviewsQuery query)
    {
        query.ProductId = productId;
        var result = await _mediator.Send(query);
        return Ok(result);
    }

    [HttpGet("staff/{staffId:int}")]
    public async Task<IActionResult> GetStaffReviews(int staffId, [FromQuery] GetStaffReviewsQuery query)
    {
        query.StaffId = staffId;
        var result = await _mediator.Send(query);
        return Ok(result);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> UpdateReview(int id, [FromBody] UpdateReviewCommand command)
    {
        command.Id = id;
        var result = await _mediator.Send(command);
        return Ok(result);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> DeleteReview(int id)
    {
        await _mediator.Send(new DeleteReviewCommand { Id = id });
        return NoContent();
    }
}
