using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.Reports;
using Stronghold.Application.Interfaces;
using Stronghold.Core;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/reports")]
[Authorize(Roles = Roles.Admin)]
public class ReportsController : ControllerBase
{
    private readonly IReportService _reportService;

    public ReportsController(IReportService reportService)
    {
        _reportService = reportService;
    }

    [HttpGet("dashboard")]
    public async Task<ActionResult<DashboardResponse>> GetDashboard()
    {
        return Ok(await _reportService.GetDashboardAsync());
    }

    /// <summary>Uplate clanarina za period od-do datuma (format GGGG-MM-DD, default zadnjih 30 dana), opciono za jednog clana.</summary>
    [HttpGet("memberships")]
    public async Task<ActionResult<MembershipsReportResponse>> GetMemberships(
        [FromQuery] string? from, [FromQuery] string? to, [FromQuery] int? userId)
    {
        return Ok(await _reportService.GetMembershipsReportAsync(from, to, userId));
    }

    /// <summary>Prodaje u prodavnici za isti oblik perioda, opciono za jednog kupca.</summary>
    [HttpGet("shop")]
    public async Task<ActionResult<ShopReportResponse>> GetShop(
        [FromQuery] string? from, [FromQuery] string? to, [FromQuery] int? userId)
    {
        return Ok(await _reportService.GetShopReportAsync(from, to, userId));
    }

    /// <summary>PDF izvjestaj za preuzimanje i ispis (memberships/shop).</summary>
    [HttpGet("{reportKey}/pdf")]
    public async Task<IActionResult> ExportPdf(
        string reportKey, [FromQuery] string? from, [FromQuery] string? to, [FromQuery] int? userId)
    {
        var bytes = await _reportService.ExportPdfAsync(reportKey, from, to, userId);
        return File(bytes, "application/pdf", $"stronghold-{reportKey}.pdf");
    }

    [HttpGet("{reportKey}/excel")]
    public async Task<IActionResult> ExportExcel(
        string reportKey, [FromQuery] string? from, [FromQuery] string? to, [FromQuery] int? userId)
    {
        var bytes = await _reportService.ExportExcelAsync(reportKey, from, to, userId);
        return File(bytes,
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            $"stronghold-{reportKey}.xlsx");
    }
}
