using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Orders;
using Stronghold.Application.Interfaces;
using Stronghold.Core;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/orders")]
[Authorize]
public class OrdersController : ControllerBase
{
    private readonly IOrderService _orderService;

    public OrdersController(IOrderService orderService)
    {
        _orderService = orderService;
    }

    [HttpGet]
    [Authorize(Roles = Roles.Admin)]
    public async Task<ActionResult<PagedResult<OrderResponse>>> GetPaged([FromQuery] OrderSearch search)
    {
        return Ok(await _orderService.GetPagedAsync(search));
    }

    [HttpGet("{id}")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<ActionResult<OrderResponse>> GetById(int id)
    {
        return Ok(await _orderService.GetByIdAsync(id));
    }

    /// <summary>Checkout korak: server racuna iznos i vraca client secret za Stripe PaymentSheet.</summary>
    [HttpPost("create-payment-intent")]
    [Authorize(Roles = Roles.GymMember)]
    public async Task<ActionResult<PaymentIntentResponse>> CreatePaymentIntent(CreatePaymentIntentRequest request)
    {
        return Ok(await _orderService.CreatePaymentIntentAsync(request));
    }

    /// <summary>Nakon placanja u aplikaciji - server verifikuje status kod Stripe-a i kreira narudzbu.</summary>
    [HttpPost("confirm")]
    [Authorize(Roles = Roles.GymMember)]
    public async Task<ActionResult<OrderResponse>> Confirm(ConfirmOrderRequest request)
    {
        return Ok(await _orderService.ConfirmAsync(request));
    }

    [HttpGet("my")]
    [Authorize(Roles = Roles.GymMember)]
    public async Task<ActionResult<PagedResult<OrderResponse>>> GetMine([FromQuery] BaseSearchObject search)
    {
        return Ok(await _orderService.GetMineAsync(search));
    }

    [HttpPut("{id}/ship")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<ActionResult<OrderResponse>> Ship(int id)
    {
        return Ok(await _orderService.ShipAsync(id));
    }

    [HttpPut("{id}/deliver")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<ActionResult<OrderResponse>> Deliver(int id)
    {
        return Ok(await _orderService.DeliverAsync(id));
    }

    /// <summary>
    /// Otkazivanje placene narudzbe vrsi stvarni Stripe refund.
    /// Dostupno i kupcu (vlastita narudzba dok nije poslana) - provjera u servisu.
    /// </summary>
    [HttpPut("{id}/cancel")]
    public async Task<ActionResult<OrderResponse>> Cancel(int id, OrderCancelRequest request)
    {
        return Ok(await _orderService.CancelAsync(id, request));
    }
}
