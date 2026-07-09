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

    /// <summary>Poslovni izvjestaj za period od-do mjeseca (format GGGG-MM, default zadnjih 6).</summary>
    [HttpGet("revenue")]
    public async Task<ActionResult<RevenueReportResponse>> GetRevenue(
        [FromQuery] string? from, [FromQuery] string? to)
    {
        return Ok(await _reportService.GetRevenueReportAsync(from, to));
    }

    /// <summary>Izvjestaj o terminima osoblja za isti oblik perioda.</summary>
    [HttpGet("staff")]
    public async Task<ActionResult<StaffReportResponse>> GetStaff(
        [FromQuery] string? from, [FromQuery] string? to)
    {
        return Ok(await _reportService.GetStaffReportAsync(from, to));
    }

    /// <summary>PDF izvjestaj za preuzimanje i ispis (revenue/staff).</summary>
    [HttpGet("{reportKey}/pdf")]
    public async Task<IActionResult> ExportPdf(
        string reportKey, [FromQuery] string? from, [FromQuery] string? to)
    {
        var bytes = await _reportService.ExportPdfAsync(reportKey, from, to);
        return File(bytes, "application/pdf", $"stronghold-{reportKey}.pdf");
    }

    [HttpGet("{reportKey}/excel")]
    public async Task<IActionResult> ExportExcel(
        string reportKey, [FromQuery] string? from, [FromQuery] string? to)
    {
        var bytes = await _reportService.ExportExcelAsync(reportKey, from, to);
        return File(bytes,
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            $"stronghold-{reportKey}.xlsx");
    }
}
