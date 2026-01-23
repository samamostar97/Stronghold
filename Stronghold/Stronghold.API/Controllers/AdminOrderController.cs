using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.AdminOrderDTO;
using Stronghold.Application.Filters;
using Stronghold.Application.IServices;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/admin/orders")]
    [Authorize(Roles = "Admin")]
    public class AdminOrderController : ControllerBase
    {
        private readonly IAdminOrderService _service;

        public AdminOrderController(IAdminOrderService service)
        {
            _service = service;
        }

        [HttpGet("GetAllPaged")]
        public async Task<ActionResult<PagedResult<OrdersDTO>>> GetAllPagedAsync(
            [FromQuery] PaginationRequest request,
            [FromQuery] OrderQueryFilter? filter)
        {
            var result = await _service.GetPagedAsync(request, filter);
            return Ok(result);
        }

        [HttpGet("GetAll")]
        public async Task<ActionResult<IEnumerable<OrdersDTO>>> GetAllAsync([FromQuery] OrderQueryFilter? filter)
        {
            var result = await _service.GetAllAsync(filter);
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<OrdersDTO>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);
            return Ok(result);
        }

        [HttpPatch("{id}/deliver")]
        public async Task<ActionResult<OrdersDTO>> MarkAsDelivered(int id)
        {
            var result = await _service.MarkAsDeliveredAsync(id);
            return Ok(result);
        }
    }
}
