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
    }

}
