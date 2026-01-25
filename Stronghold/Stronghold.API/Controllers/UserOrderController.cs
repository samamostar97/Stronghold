using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.UserDTOs;
using Stronghold.Application.IServices;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/user/order")]
    [Authorize]
    public class UserOrderController : UserControllerBase
    {
        private readonly IUserOrderService _userOrderService;

        public UserOrderController(IUserOrderService userOrderService)
        {
            _userOrderService = userOrderService;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<UserOrdersDTO>>> GetOrderList()
        {
            var userId = GetCurrentUserId();
            if (userId == null) return Unauthorized();

            var result = await _userOrderService.GetOrderList(userId.Value);
            return Ok(result);
        }
    }
}
