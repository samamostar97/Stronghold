using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Features.Cart.AddToCart;
using Stronghold.Application.Features.Cart.ClearCart;
using Stronghold.Application.Features.Cart.GetCart;
using Stronghold.Application.Features.Cart.RemoveCartItem;
using Stronghold.Application.Features.Cart.UpdateCartItem;

namespace Stronghold.API.Controllers;

[ApiController]
[Authorize]
[Route("api/cart")]
public class CartController : ControllerBase
{
    private readonly IMediator _mediator;

    public CartController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<IActionResult> GetCart()
    {
        var result = await _mediator.Send(new GetCartQuery());
        return Ok(result);
    }

    [HttpPost("items")]
    public async Task<IActionResult> AddToCart([FromBody] AddToCartCommand command)
    {
        var result = await _mediator.Send(command);
        return StatusCode(201, result);
    }

    [HttpPut("items/{id:int}")]
    public async Task<IActionResult> UpdateCartItem(int id, [FromBody] UpdateCartItemCommand command)
    {
        command.Id = id;
        var result = await _mediator.Send(command);
        return Ok(result);
    }

    [HttpDelete("items/{id:int}")]
    public async Task<IActionResult> RemoveCartItem(int id)
    {
        await _mediator.Send(new RemoveCartItemCommand { Id = id });
        return NoContent();
    }

    [HttpDelete]
    public async Task<IActionResult> ClearCart()
    {
        await _mediator.Send(new ClearCartCommand());
        return NoContent();
    }
}
