using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.UserDTOs;
using Stronghold.Application.IServices;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/user/checkout")]
    [Authorize]
    public class UserCheckoutController : UserControllerBase
    {
        private readonly ICheckoutService _checkoutService;

        public UserCheckoutController(ICheckoutService checkoutService)
        {
            _checkoutService = checkoutService;
        }

        [HttpPost]
        public async Task<ActionResult<CheckoutResponseDTO>> CreatePaymentIntent([FromBody] CheckoutRequestDTO request)
        {
            var userId = GetCurrentUserId();
            if (userId == null) return Unauthorized();

            var result = await _checkoutService.CreatePaymentIntent(userId.Value, request);
            return Ok(result);
        }

        [HttpPost("confirm")]
        public async Task<ActionResult<UserOrdersDTO>> ConfirmOrder([FromBody] ConfirmOrderDTO request)
        {
            var userId = GetCurrentUserId();
            if (userId == null) return Unauthorized();

            var result = await _checkoutService.ConfirmOrder(userId.Value, request);
            return Ok(result);
        }
    }
}
