using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Features.Wishlist.AddToWishlist;
using Stronghold.Application.Features.Wishlist.GetWishlist;
using Stronghold.Application.Features.Wishlist.RemoveFromWishlist;

namespace Stronghold.API.Controllers;

[ApiController]
[Authorize]
[Route("api/wishlist")]
public class WishlistController : ControllerBase
{
    private readonly IMediator _mediator;

    public WishlistController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<IActionResult> GetWishlist()
    {
        var result = await _mediator.Send(new GetWishlistQuery());
        return Ok(result);
    }

    [HttpPost("{productId:int}")]
    public async Task<IActionResult> AddToWishlist(int productId)
    {
        var result = await _mediator.Send(new AddToWishlistCommand { ProductId = productId });
        return StatusCode(201, result);
    }

    [HttpDelete("{productId:int}")]
    public async Task<IActionResult> RemoveFromWishlist(int productId)
    {
        await _mediator.Send(new RemoveFromWishlistCommand { ProductId = productId });
        return NoContent();
    }
}
