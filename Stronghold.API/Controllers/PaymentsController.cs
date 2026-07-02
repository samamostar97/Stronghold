using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Payments;
using Stronghold.Application.Interfaces;
using Stronghold.Core;

namespace Stronghold.API.Controllers;

/// <summary>Historija uplata clanarina - pregled svih uplata u sistemu.</summary>
[ApiController]
[Route("api/payments")]
[Authorize(Roles = Roles.Admin)]
public class PaymentsController : ControllerBase
{
    private readonly IPaymentService _paymentService;

    public PaymentsController(IPaymentService paymentService)
    {
        _paymentService = paymentService;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<PaymentResponse>>> GetPaged([FromQuery] PaymentSearch search)
    {
        return Ok(await _paymentService.GetPagedAsync(search));
    }
}
