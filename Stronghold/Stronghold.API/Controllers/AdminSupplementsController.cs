using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.AdminSupplementsDTO;
using Stronghold.Application.IServices;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/admin/supplements")]
    [Authorize(Roles = "Admin")]
    public class AdminSupplementsController : ControllerBase
    {
        private readonly IAdminSupplementService _adminSupplementService;
        public AdminSupplementsController(IAdminSupplementService adminSupplementService)
        {
            _adminSupplementService = adminSupplementService;
        }
        [HttpGet("all-supplements")]
        public async Task<IEnumerable<SupplementDTO>> GetSupplements([FromQuery]string? search)
        {
            return await _adminSupplementService.GetSupplementsAsync(search);
        }
        [HttpGet("{id:int}")]
        public async Task<ActionResult<SupplementDTO>> GetById(int id)
        {
            var supplement = await _adminSupplementService.GetSupplementByIdAsync(id);
            if (supplement == null)
                return NotFound();
            return Ok(supplement);
        }

        [HttpPost]
        public async Task<ActionResult> AddSupplement([FromBody] CreateSupplementDTO dto)
        {
            var id = await _adminSupplementService.AddAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id }, new { id });
        }
        [HttpDelete("{id:int}")]
        public async Task<ActionResult> SoftDelete(int id)
        {
            var ok = await _adminSupplementService.SoftDeleteAsync(id);
            if (!ok) return NotFound();
            return NoContent();
        }
        [HttpPut("{id:int}")]
        public async Task<ActionResult> UpdateSupplement(int id, [FromBody] UpdateSupplementDTO dto)
        {
            var ok = await _adminSupplementService.UpdateAsync(id, dto);
            if (!ok) return NotFound();
            return NoContent();
        }
    }
}
