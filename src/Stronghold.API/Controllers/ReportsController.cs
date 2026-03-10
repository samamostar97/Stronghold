using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Features.Reports.AppointmentsReport;
using Stronghold.Application.Features.Reports.MembershipRevenueReport;
using Stronghold.Application.Features.Reports.OrderRevenueReport;
using Stronghold.Application.Features.Reports.ProductsReport;
using Stronghold.Application.Features.Reports.RevenueReport;
using Stronghold.Application.Features.Reports.UsersReport;

namespace Stronghold.API.Controllers;

[ApiController]
[Authorize]
[Route("api/reports")]
public class ReportsController : ControllerBase
{
    private readonly IMediator _mediator;

    public ReportsController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet("revenue")]
    public async Task<IActionResult> GetRevenueReport([FromQuery] RevenueReportQuery query)
    {
        var result = await _mediator.Send(query);
        return File(result.FileContent, result.ContentType, result.FileName);
    }

    [HttpGet("revenue/orders")]
    public async Task<IActionResult> GetOrderRevenueReport([FromQuery] OrderRevenueReportQuery query)
    {
        var result = await _mediator.Send(query);
        return File(result.FileContent, result.ContentType, result.FileName);
    }

    [HttpGet("revenue/memberships")]
    public async Task<IActionResult> GetMembershipRevenueReport([FromQuery] MembershipRevenueReportQuery query)
    {
        var result = await _mediator.Send(query);
        return File(result.FileContent, result.ContentType, result.FileName);
    }

    [HttpGet("users")]
    public async Task<IActionResult> GetUsersReport([FromQuery] UsersReportQuery query)
    {
        var result = await _mediator.Send(query);
        return File(result.FileContent, result.ContentType, result.FileName);
    }

    [HttpGet("products")]
    public async Task<IActionResult> GetProductsReport([FromQuery] ProductsReportQuery query)
    {
        var result = await _mediator.Send(query);
        return File(result.FileContent, result.ContentType, result.FileName);
    }

    [HttpGet("appointments")]
    public async Task<IActionResult> GetAppointmentsReport([FromQuery] AppointmentsReportQuery query)
    {
        var result = await _mediator.Send(query);
        return File(result.FileContent, result.ContentType, result.FileName);
    }
}
