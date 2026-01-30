using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.AdminSupplementsDTO;
using Stronghold.Application.Filters;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/admin/supplements")]
    [Authorize(Roles ="Admin")]
    public class AdminSupplementController : BaseController<Supplement, SupplementDTO, CreateSupplementDTO, UpdateSupplementDTO, SupplementQueryFilter, int>
    {
        private readonly IAdminSupplementService _adminSupplementService;
        public AdminSupplementController(IAdminSupplementService service) : base(service)
        {
            _adminSupplementService = service;
        }
        [HttpPost("{id}/image")]
        public async Task<ActionResult<SupplementDTO>> UploadImage(int id, IFormFile file)
        {
            if (file == null || file.Length == 0)
                return BadRequest("Nije odabrana slika");

            var fileRequest = new FileUploadRequest
            {
                FileStream = file.OpenReadStream(),
                FileName = file.FileName,
                ContentType = file.ContentType,
                FileSize = file.Length
            };

            var result = await _adminSupplementService.UploadImageAsync(id, fileRequest);
            return Ok(result);
        }

        [HttpDelete("{id}/image")]
        public async Task<IActionResult> DeleteImage(int id)
        {
            await _adminSupplementService.DeleteImageAsync(id);
            return NoContent();
        }
    }
}

