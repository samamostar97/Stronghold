using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.UserDTOs;
using Stronghold.Application.IServices;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/user/supplement")]
    [Authorize]
    public class UserSupplementController : UserControllerBase
    {
        private readonly IUserSupplementService _supplementService;

        public UserSupplementController(IUserSupplementService supplementService)
        {
            _supplementService = supplementService;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<UserSupplementDTO>>> GetSupplements(
            [FromQuery] PaginationRequest pagination,
            [FromQuery] string? search,
            [FromQuery] int? categoryId)
        {
            var result = await _supplementService.GetSupplementsPaged(pagination, search, categoryId);
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<UserSupplementDTO>> GetById(int id)
        {
            var result = await _supplementService.GetById(id);
            return Ok(result);
        }

        [HttpGet("categories")]
        public async Task<ActionResult<IEnumerable<UserSupplementCategoryDTO>>> GetCategories()
        {
            var result = await _supplementService.GetCategories();
            return Ok(result);
        }

        [HttpGet("{id}/reviews")]
        public async Task<ActionResult<IEnumerable<SupplementReviewDTO>>> GetReviews(int id)
        {
            var result = await _supplementService.GetReviewsBySupplementId(id);
            return Ok(result);
        }
    }
}
