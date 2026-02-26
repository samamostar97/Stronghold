using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Reports.DTOs;
using Stronghold.Application.Features.Reports.Queries;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/reports")]
    [Authorize]
    public class ReportsController : ControllerBase
    {
        private readonly IMediator _mediator;

        public ReportsController(IMediator mediator)
        {
            _mediator = mediator;
        }

        [HttpGet("business")]
        public async Task<ActionResult<BusinessReportResponse>> GetBusinessReport([FromQuery] int days = 30)
        {
            var report = await _mediator.Send(new GetBusinessReportQuery { Days = days });
            return Ok(report);
        }

        [HttpGet("inventory")]
        public async Task<ActionResult<InventoryReportResponse>> GetInventoryReport([FromQuery] int daysToAnalyze = 30)
        {
            var report = await _mediator.Send(new GetInventoryReportQuery { DaysToAnalyze = daysToAnalyze });
            return Ok(report);
        }

        [HttpGet("inventory/summary")]
        public async Task<ActionResult<InventorySummaryResponse>> GetInventorySummary([FromQuery] int daysToAnalyze = 30)
        {
            var summary = await _mediator.Send(new GetInventorySummaryQuery { DaysToAnalyze = daysToAnalyze });
            return Ok(summary);
        }

        [HttpGet("inventory/slow-moving")]
        public async Task<ActionResult<PagedResult<SlowMovingProductResponse>>> GetSlowMovingProducts([FromQuery] SlowMovingProductQueryFilter filter)
        {
            var result = await _mediator.Send(new GetSlowMovingProductsQuery { Filter = filter });
            return Ok(result);
        }

        [HttpGet("membership-popularity")]
        public async Task<ActionResult<MembershipPopularityReportResponse>> GetMembershipPopularityReport([FromQuery] int days = 90)
        {
            var report = await _mediator.Send(new GetMembershipPopularityReportQuery { Days = days });
            return Ok(report);
        }

        [HttpGet("export/excel")]
        public async Task<IActionResult> ExportToExcel()
        {
            var fileBytes = await _mediator.Send(new ExportBusinessReportExcelQuery());
            var fileName = $"Stronghold_Izvjestaj_{StrongholdTimeUtils.LocalNow:yyyyMMdd_HHmm}.xlsx";
            return File(fileBytes, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", fileName);
        }

        [HttpGet("export/pdf")]
        public async Task<IActionResult> ExportToPdf()
        {
            var fileBytes = await _mediator.Send(new ExportBusinessReportPdfQuery());
            var fileName = $"Stronghold_Izvjestaj_{StrongholdTimeUtils.LocalNow:yyyyMMdd_HHmm}.pdf";
            return File(fileBytes, "application/pdf", fileName);
        }

        [HttpGet("inventory/export/excel")]
        public async Task<IActionResult> ExportInventoryToExcel([FromQuery] int daysToAnalyze = 30)
        {
            var fileBytes = await _mediator.Send(new ExportInventoryReportExcelQuery { DaysToAnalyze = daysToAnalyze });
            var fileName = $"Stronghold_Inventar_{StrongholdTimeUtils.LocalNow:yyyyMMdd_HHmm}.xlsx";
            return File(fileBytes, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", fileName);
        }

        [HttpGet("inventory/export/pdf")]
        public async Task<IActionResult> ExportInventoryToPdf([FromQuery] int daysToAnalyze = 30)
        {
            var fileBytes = await _mediator.Send(new ExportInventoryReportPdfQuery { DaysToAnalyze = daysToAnalyze });
            var fileName = $"Stronghold_Inventar_{StrongholdTimeUtils.LocalNow:yyyyMMdd_HHmm}.pdf";
            return File(fileBytes, "application/pdf", fileName);
        }

        [HttpGet("membership-popularity/export/excel")]
        public async Task<IActionResult> ExportMembershipPopularityToExcel()
        {
            var fileBytes = await _mediator.Send(new ExportMembershipPopularityExcelQuery());
            var fileName = $"Stronghold_Clanarine_{StrongholdTimeUtils.LocalNow:yyyyMMdd_HHmm}.xlsx";
            return File(fileBytes, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", fileName);
        }

        [HttpGet("membership-popularity/export/pdf")]
        public async Task<IActionResult> ExportMembershipPopularityToPdf()
        {
            var fileBytes = await _mediator.Send(new ExportMembershipPopularityPdfQuery());
            var fileName = $"Stronghold_Clanarine_{StrongholdTimeUtils.LocalNow:yyyyMMdd_HHmm}.pdf";
            return File(fileBytes, "application/pdf", fileName);
        }

        [HttpGet("activity")]
        public async Task<ActionResult<IReadOnlyList<ActivityFeedItemResponse>>> GetActivityFeed([FromQuery] int count = 20)
        {
            var feed = await _mediator.Send(new GetActivityFeedQuery { Count = count });
            return Ok(feed);
        }
    }
}
