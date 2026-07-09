using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.Cart;
using Stronghold.Application.Interfaces;
using Stronghold.Core;

namespace Stronghold.API.Controllers;

/// <summary>Korpa clana - server je izvor istine (ista korpa na svim uredjajima).</summary>
[ApiController]
[Route("api/cart")]
[Authorize(Roles = Roles.GymMember)]
public class CartController : ControllerBase
{
    private readonly ICartService _cartService;

    public CartController(ICartService cartService)
    {
        _cartService = cartService;
    }

    [HttpGet]
    public async Task<ActionResult<CartResponse>> GetMine()
    {
        return Ok(await _cartService.GetMineAsync());
    }

    /// <summary>Dodaje suplement ili povecava kolicinu postojece stavke.</summary>
    [HttpPost("items")]
    public async Task<ActionResult<CartResponse>> AddItem(AddCartItemRequest request)
    {
        return Ok(await _cartService.AddItemAsync(request));
    }

    [HttpPut("items/{supplementId}")]
    public async Task<ActionResult<CartResponse>> UpdateItem(int supplementId, UpdateCartItemRequest request)
    {
        return Ok(await _cartService.UpdateItemAsync(supplementId, request));
    }

    [HttpDelete("items/{supplementId}")]
    public async Task<ActionResult<CartResponse>> RemoveItem(int supplementId)
    {
        return Ok(await _cartService.RemoveItemAsync(supplementId));
    }

    [HttpDelete]
    public async Task<ActionResult<CartResponse>> Clear()
    {
        return Ok(await _cartService.ClearAsync());
    }
}
