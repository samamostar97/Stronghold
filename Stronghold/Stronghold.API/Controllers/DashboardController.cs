using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Features.Dashboard.DTOs;
using Stronghold.Application.Features.Dashboard.Queries;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/dashboard")]
    [Authorize]
    public class DashboardController : ControllerBase
    {
        private readonly IMediator _mediator;

        public DashboardController(IMediator mediator)
        {
            _mediator = mediator;
        }

        [HttpGet("overview")]
        public async Task<ActionResult<DashboardOverviewResponse>> GetOverview([FromQuery] int days = 30)
        {
            var report = await _mediator.Send(new GetDashboardOverviewQuery { Days = days });
            return Ok(report);
        }

        [HttpGet("sales")]
        public async Task<ActionResult<DashboardSalesResponse>> GetSales()
        {
            var report = await _mediator.Send(new GetDashboardSalesQuery());
            return Ok(report);
        }

        [HttpGet("attention")]
        public async Task<ActionResult<DashboardAttentionResponse>> GetAttention([FromQuery] int days = 7)
        {
            var report = await _mediator.Send(new GetDashboardAttentionQuery { Days = days });
            return Ok(report);
        }
    }
}
