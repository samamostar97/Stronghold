using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Features.Orders.ConfirmOrder;
using Stronghold.Application.Features.Orders.CreateOrder;
using Stronghold.Application.Features.Orders.GetMyOrders;
using Stronghold.Application.Features.Orders.GetOrderById;
using Stronghold.Application.Features.Orders.GetOrders;
using Stronghold.Application.Features.Orders.ShipOrder;

namespace Stronghold.API.Controllers;

[ApiController]
[Authorize]
[Route("api/orders")]
public class OrdersController : ControllerBase
{
    private readonly IMediator _mediator;

    public OrdersController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpPost]
    public async Task<IActionResult> CreateOrder([FromBody] CreateOrderCommand command)
    {
        var result = await _mediator.Send(command);
        return StatusCode(201, result);
    }

    [HttpPost("{id:int}/confirm")]
    public async Task<IActionResult> ConfirmOrder(int id)
    {
        var result = await _mediator.Send(new ConfirmOrderCommand { Id = id });
        return Ok(result);
    }

    [HttpGet("my")]
    public async Task<IActionResult> GetMyOrders([FromQuery] GetMyOrdersQuery query)
    {
        var result = await _mediator.Send(query);
        return Ok(result);
    }

    [HttpGet]
    public async Task<IActionResult> GetOrders([FromQuery] GetOrdersQuery query)
    {
        var result = await _mediator.Send(query);
        return Ok(result);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetOrderById(int id)
    {
        var result = await _mediator.Send(new GetOrderByIdQuery { Id = id });
        return Ok(result);
    }

    [HttpPut("{id:int}/ship")]
    public async Task<IActionResult> ShipOrder(int id)
    {
        var result = await _mediator.Send(new ShipOrderCommand { Id = id });
        return Ok(result);
    }
}
