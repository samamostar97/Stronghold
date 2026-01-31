using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.AdminReviewDTO;
using Stronghold.Application.Filters;
using Stronghold.Application.IServices;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/admin/review")]
    [Authorize(Roles = "Admin")]

    public class AdminReviewController: ControllerBase
    {
        private readonly IAdminReviewService _service;
        public AdminReviewController(IAdminReviewService service)
        {
            _service = service;
        }
        [HttpGet("GetPaged")]
        public async Task<ActionResult<PagedResult<ReviewDTO>>> GetReviewPaged([FromQuery]PaginationRequest request, 
                                                                         [FromQuery]ReviewQueryFilter? queryFilter)
        {
            var result = await _service.GetReviewsPagedAsync(request, queryFilter);
            return Ok(result);
        }
        [HttpDelete("{id}")]
        public async Task<ActionResult<ReviewDTO>> DeleteReview(int id)
        {
            var result = await _service.DeleteReviewAsync(id);
            return Ok(result);
        }
    }
}
