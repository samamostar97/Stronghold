using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Orders.Commands;
using Stronghold.Application.Features.Orders.DTOs;
using Stronghold.Application.Features.Orders.Queries;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/orders")]
    [Authorize]
    public class OrderController : ControllerBase
    {
        private readonly IMediator _mediator;

        public OrderController(IMediator mediator)
        {
            _mediator = mediator;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<OrderResponse>>> GetAllPagedAsync([FromQuery] OrderFilter filter)
        {
            var result = await _mediator.Send(new GetPagedOrdersQuery { Filter = filter });
            return Ok(result);
        }

        [HttpGet("all")]
        public async Task<ActionResult<IEnumerable<OrderResponse>>> GetAllAsync([FromQuery] OrderFilter? filter)
        {
            var result = await _mediator.Send(new GetOrdersQuery { Filter = filter });
            return Ok(result);
        }

        [HttpGet("{id:int}")]
        public async Task<ActionResult<OrderResponse>> GetById(int id)
        {
            var result = await _mediator.Send(new GetOrderByIdQuery { OrderId = id });
            return Ok(result);
        }

        [HttpPatch("{id}/deliver")]
        public async Task<ActionResult<OrderResponse>> MarkAsDelivered(int id)
        {
            var result = await _mediator.Send(new MarkOrderAsDeliveredCommand { OrderId = id });
            return Ok(result);
        }

        [HttpPatch("{id:int}/cancel")]
        public async Task<ActionResult<OrderResponse>> CancelOrder(int id, [FromBody] CancelOrderCommand? command)
        {
            command ??= new CancelOrderCommand();
            command.OrderId = id;
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        [HttpGet("my")]
        public async Task<ActionResult<PagedResult<UserOrderResponse>>> GetMyOrders([FromQuery] OrderFilter filter)
        {
            var result = await _mediator.Send(new GetMyOrdersQuery { Filter = filter });
            return Ok(result);
        }

        [HttpPost("checkout")]
        public async Task<ActionResult<CheckoutResponse>> CreatePaymentIntent([FromBody] CreateCheckoutPaymentIntentCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        [HttpPost("checkout/confirm")]
        public async Task<ActionResult<UserOrderResponse>> ConfirmOrder([FromBody] ConfirmOrderCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }
    }
}
