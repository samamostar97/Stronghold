using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Filters;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/reviews")]
    public class ReviewController : BaseController<Review, ReviewResponse, CreateReviewRequest, UpdateReviewRequest, ReviewQueryFilter, int>
    {
        private readonly IReviewService _reviewService;

        public ReviewController(IReviewService service) : base(service)
        {
            _reviewService = service;
        }

        // =====================
        // User endpoints (ownership-based)
        // =====================

        [HttpGet("my")]
        [Authorize(Roles = "GymMember")]
        public async Task<ActionResult<PagedResult<UserReviewResponse>>> GetMyReviews([FromQuery] ReviewQueryFilter filter)
        {
            var userId = GetCurrentUserId();
            if (userId == null) return Unauthorized();

            var result = await _reviewService.GetReviewsByUserIdAsync(userId.Value, filter);
            return Ok(result);
        }

        [HttpGet("available-supplements")]
        [Authorize(Roles = "GymMember")]
        public async Task<ActionResult<PagedResult<PurchasedSupplementResponse>>> GetAvailableSupplements([FromQuery] ReviewQueryFilter filter)
        {
            var userId = GetCurrentUserId();
            if (userId == null) return Unauthorized();

            var result = await _reviewService.GetPurchasedSupplementsForReviewAsync(userId.Value, filter);
            return Ok(result);
        }

        [HttpGet("GetAllPaged")]
        [Authorize(Roles = "Admin,GymMember")]
        public override Task<ActionResult<PagedResult<ReviewResponse>>> GetAllPagedAsync([FromQuery] ReviewQueryFilter filter)
        {
            return base.GetAllPagedAsync(filter);
        }

        [HttpGet("GetAll")]
        [Authorize(Roles = "Admin,GymMember")]
        public override Task<ActionResult<IEnumerable<ReviewResponse>>> GetAllAsync([FromQuery] ReviewQueryFilter filter)
        {
            return base.GetAllAsync(filter);
        }

        [HttpGet("{id}")]
        [Authorize(Roles = "Admin,GymMember")]
        public override Task<ActionResult<ReviewResponse>> GetById(int id)
        {
            return base.GetById(id);
        }

        [HttpPost]
        [Authorize(Roles = "GymMember")]
        public override async Task<ActionResult<ReviewResponse>> Create([FromBody] CreateReviewRequest dto)
        {
            var userId = GetCurrentUserId();
            if (userId == null) return Unauthorized();

            dto.UserId = userId.Value;
            var result = await _service.CreateAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = result!.GetType().GetProperty("Id")?.GetValue(result) }, result);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "GymMember")]
        public override Task<ActionResult<ReviewResponse>> Update(int id, [FromBody] UpdateReviewRequest dto)
        {
            return Task.FromResult<ActionResult<ReviewResponse>>(BadRequest("Recenzije se ne mogu mijenjati"));
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "GymMember,Admin")]
        public override async Task<IActionResult> Delete(int id)
        {
            var userId = GetCurrentUserId();
            if (userId == null) return Unauthorized();

            // Admin can delete any review
            if (User.IsInRole("Admin"))
            {
                await _service.DeleteAsync(id);
                return NoContent();
            }

            // User can only delete their own review
            if (!await _reviewService.IsOwnerAsync(id, userId.Value))
                return Forbid();

            await _service.DeleteAsync(id);
            return NoContent();
        }
    }
}
