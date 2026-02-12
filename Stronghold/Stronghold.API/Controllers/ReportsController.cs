using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Filters;
using Stronghold.Application.IServices;


namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/reports")]
    [Authorize(Roles = "Admin")]
    public class ReportsController : ControllerBase
    {
        private readonly IReportService _reportsService;

        public ReportsController(IReportService reportsService)
        {
            _reportsService = reportsService;
        }

        [HttpGet("business")]
        public async Task<ActionResult<BusinessReportResponse>> GetBusinessReport()
        {
            var report = await _reportsService.GetBusinessReportAsync();
            return Ok(report);
        }

        [HttpGet("inventory")]
        public async Task<ActionResult<InventoryReportResponse>> GetInventoryReport([FromQuery] int daysToAnalyze = 30)
        {
            var report = await _reportsService.GetInventoryReportAsync(daysToAnalyze);
            return Ok(report);
        }

        [HttpGet("inventory/summary")]
        public async Task<ActionResult<InventorySummaryResponse>> GetInventorySummary([FromQuery] int daysToAnalyze = 30)
        {
            var summary = await _reportsService.GetInventorySummaryAsync(daysToAnalyze);
            return Ok(summary);
        }

        [HttpGet("inventory/slow-moving")]
        public async Task<ActionResult<PagedResult<SlowMovingProductResponse>>> GetSlowMovingProducts([FromQuery] SlowMovingProductQueryFilter filter)
        {
            var result = await _reportsService.GetSlowMovingProductsPagedAsync(filter);
            return Ok(result);
        }

        [HttpGet("membership-popularity")]
        public async Task<ActionResult<MembershipPopularityReportResponse>> GetMembershipPopularityReport()
        {
            var report = await _reportsService.GetMembershipPopularityReportAsync();
            return Ok(report);
        }

        [HttpGet("export/excel")]
        public async Task<IActionResult> ExportToExcel()
        {
            var fileBytes = await _reportsService.ExportToExcelAsync();
            var fileName = $"Stronghold_Izvjestaj_{StrongholdTimeUtils.LocalNow:yyyyMMdd_HHmm}.xlsx";
            return File(fileBytes, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", fileName);
        }

        [HttpGet("export/pdf")]
        public async Task<IActionResult> ExportToPdf()
        {
            var fileBytes = await _reportsService.ExportToPdfAsync();
            var fileName = $"Stronghold_Izvjestaj_{StrongholdTimeUtils.LocalNow:yyyyMMdd_HHmm}.pdf";
            return File(fileBytes, "application/pdf", fileName);
        }

        [HttpGet("inventory/export/excel")]
        public async Task<IActionResult> ExportInventoryToExcel([FromQuery] int daysToAnalyze = 30)
        {
            var fileBytes = await _reportsService.ExportInventoryReportToExcelAsync(daysToAnalyze);
            var fileName = $"Stronghold_Inventar_{StrongholdTimeUtils.LocalNow:yyyyMMdd_HHmm}.xlsx";
            return File(fileBytes, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", fileName);
        }

        [HttpGet("inventory/export/pdf")]
        public async Task<IActionResult> ExportInventoryToPdf([FromQuery] int daysToAnalyze = 30)
        {
            var fileBytes = await _reportsService.ExportInventoryReportToPdfAsync(daysToAnalyze);
            var fileName = $"Stronghold_Inventar_{StrongholdTimeUtils.LocalNow:yyyyMMdd_HHmm}.pdf";
            return File(fileBytes, "application/pdf", fileName);
        }

        [HttpGet("membership-popularity/export/excel")]
        public async Task<IActionResult> ExportMembershipPopularityToExcel()
        {
            var fileBytes = await _reportsService.ExportMembershipPopularityToExcelAsync();
            var fileName = $"Stronghold_Clanarine_{StrongholdTimeUtils.LocalNow:yyyyMMdd_HHmm}.xlsx";
            return File(fileBytes, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", fileName);
        }

        [HttpGet("membership-popularity/export/pdf")]
        public async Task<IActionResult> ExportMembershipPopularityToPdf()
        {
            var fileBytes = await _reportsService.ExportMembershipPopularityToPdfAsync();
            var fileName = $"Stronghold_Clanarine_{StrongholdTimeUtils.LocalNow:yyyyMMdd_HHmm}.pdf";
            return File(fileBytes, "application/pdf", fileName);
        }

        [HttpGet("activity")]
        public async Task<ActionResult<List<ActivityFeedItemResponse>>> GetActivityFeed([FromQuery] int count = 20)
        {
            var feed = await _reportsService.GetActivityFeedAsync(count);
            return Ok(feed);
        }
    }
}
