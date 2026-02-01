using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.AdminReportsDTO;
using Stronghold.Application.IServices;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/admin/report")]
    [Authorize(Roles = "Admin")]
    public class AdminReportsController : ControllerBase
    {
        private readonly IReportService _reportsService;

        public AdminReportsController(IReportService reportsService)
        {
            _reportsService = reportsService;
        }

        [HttpGet("business")]
        public async Task<ActionResult<BusinessReportDTO>> GetBusinessReport()
        {
            var report = await _reportsService.GetBusinessReportAsync();
            return Ok(report);
        }

        [HttpGet("export/excel")]
        public async Task<IActionResult> ExportToExcel()
        {
            var fileBytes = await _reportsService.ExportToExcelAsync();
            var fileName = $"Stronghold_Izvjestaj_{DateTime.Now:yyyyMMdd_HHmm}.xlsx";
            return File(fileBytes, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", fileName);
        }

        [HttpGet("export/pdf")]
        public async Task<IActionResult> ExportToPdf()
        {
            var fileBytes = await _reportsService.ExportToPdfAsync();
            var fileName = $"Stronghold_Izvjestaj_{DateTime.Now:yyyyMMdd_HHmm}.pdf";
            return File(fileBytes, "application/pdf", fileName);
        }
    }
}
