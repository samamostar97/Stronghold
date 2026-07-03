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

    [HttpGet("revenue")]
    public async Task<ActionResult<RevenueReportResponse>> GetRevenue()
    {
        return Ok(await _reportService.GetRevenueReportAsync());
    }

    [HttpGet("inventory")]
    public async Task<ActionResult<InventoryReportResponse>> GetInventory()
    {
        return Ok(await _reportService.GetInventoryReportAsync());
    }

    [HttpGet("memberships")]
    public async Task<ActionResult<MembershipReportResponse>> GetMemberships()
    {
        return Ok(await _reportService.GetMembershipReportAsync());
    }

    /// <summary>PDF izvjestaj za preuzimanje i ispis (revenue/inventory/memberships).</summary>
    [HttpGet("{reportKey}/pdf")]
    public async Task<IActionResult> ExportPdf(string reportKey)
    {
        var bytes = await _reportService.ExportPdfAsync(reportKey);
        return File(bytes, "application/pdf", $"stronghold-{reportKey}.pdf");
    }

    [HttpGet("{reportKey}/excel")]
    public async Task<IActionResult> ExportExcel(string reportKey)
    {
        var bytes = await _reportService.ExportExcelAsync(reportKey);
        return File(bytes,
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            $"stronghold-{reportKey}.xlsx");
    }
}
