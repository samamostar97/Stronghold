using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Filters;
using Stronghold.Application.IServices;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/orders")]
    public class OrderController : UserControllerBase
    {
        private readonly IOrderService _service;

        public OrderController(IOrderService service)
        {
            _service = service;
        }

        [Authorize(Roles = "Admin")]
        [HttpGet("GetAllPaged")]
        public async Task<ActionResult<PagedResult<OrderResponse>>> GetAllPagedAsync([FromQuery] OrderQueryFilter filter)
        {
            var result = await _service.GetPagedAsync(filter);
            return Ok(result);
        }

        [Authorize(Roles = "Admin")]
        [HttpGet("GetAll")]
        public async Task<ActionResult<IEnumerable<OrderResponse>>> GetAllAsync([FromQuery] OrderQueryFilter? filter)
        {
            var result = await _service.GetAllAsync(filter);
            return Ok(result);
        }

        [Authorize(Roles = "Admin")]
        [HttpGet("{id:int}")]
        public async Task<ActionResult<OrderResponse>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);
            return Ok(result);
        }

        [Authorize(Roles = "Admin")]
        [HttpPatch("{id}/deliver")]
        public async Task<ActionResult<OrderResponse>> MarkAsDelivered(int id)
        {
            var result = await _service.MarkAsDeliveredAsync(id);
            return Ok(result);
        }

        [Authorize(Roles = "Admin")]
        [HttpPatch("{id}/cancel")]
        public async Task<ActionResult<OrderResponse>> CancelOrder(int id, [FromBody] CancelOrderRequest? request)
        {
            var result = await _service.CancelOrderAsync(id, request?.Reason);
            return Ok(result);
        }

        [Authorize]
        [HttpGet("my")]
        public async Task<ActionResult<PagedResult<UserOrderResponse>>> GetMyOrders([FromQuery] OrderQueryFilter filter)
        {
            var userId = GetCurrentUserId();
            if (userId == null) return Unauthorized();

            var result = await _service.GetOrdersByUserIdAsync(userId.Value, filter);
            return Ok(result);
        }

        [Authorize]
        [HttpPost("checkout")]
        public async Task<ActionResult<CheckoutResponse>> CreatePaymentIntent([FromBody] CheckoutRequest request)
        {
            var userId = GetCurrentUserId();
            if (userId == null) return Unauthorized();

            var result = await _service.CreatePaymentIntentAsync(userId.Value, request);
            return Ok(result);
        }

        [Authorize]
        [HttpPost("checkout/confirm")]
        public async Task<ActionResult<UserOrderResponse>> ConfirmOrder([FromBody] ConfirmOrderRequest request)
        {
            var userId = GetCurrentUserId();
            if (userId == null) return Unauthorized();

            var result = await _service.ConfirmOrderAsync(userId.Value, request);
            return Ok(result);
        }
    }
}
