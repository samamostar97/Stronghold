using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Filters;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/supplements")]
    public class SupplementController : BaseController<Supplement, SupplementResponse, CreateSupplementRequest, UpdateSupplementRequest, SupplementQueryFilter, int>
    {
        private readonly ISupplementService _supplementService;

        public SupplementController(ISupplementService service) : base(service)
        {
            _supplementService = service;
        }

        [Authorize(Roles ="Admin")]
        [HttpDelete("{id}")]
        public override Task<IActionResult> Delete(int id)
        {
            return base.Delete(id);
        }
        [Authorize(Roles ="Admin")]
        [HttpPut("{id}")]
        public override Task<ActionResult<SupplementResponse>> Update(int id, [FromBody] UpdateSupplementRequest dto)
        {
            return base.Update(id, dto);
        }
        [Authorize(Roles ="Admin")]
        [HttpPost]
        public override Task<ActionResult<SupplementResponse>> Create([FromBody] CreateSupplementRequest dto)
        {
            return base.Create(dto);
        }
        [Authorize(Roles ="Admin")]
        [HttpPost("{id}/image")]
        public async Task<ActionResult<SupplementResponse>> UploadImage(int id, IFormFile file)
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

            var result = await _supplementService.UploadImageAsync(id, fileRequest);
            return Ok(result);
        }
        [Authorize(Roles ="Admin")]
        [HttpDelete("{id}/image")]
        public async Task<IActionResult> DeleteImage(int id)
        {
            await _supplementService.DeleteImageAsync(id);
            return NoContent();
        }

        [Authorize(Roles ="Admin,GymMember")] 
        [HttpGet("GetAll")]
        public override Task<ActionResult<IEnumerable<SupplementResponse>>> GetAllAsync([FromQuery] SupplementQueryFilter filter)
        {
            return base.GetAllAsync(filter);
        }
        [Authorize(Roles ="Admin,GymMember")] 
        [HttpGet("GetAllPaged")]
        public override Task<ActionResult<PagedResult<SupplementResponse>>> GetAllPagedAsync([FromQuery] SupplementQueryFilter filter)
            => base.GetAllPagedAsync(filter);
       
        [Authorize(Roles ="Admin,GymMember")] 
        [HttpGet("{id}")]
        public override Task<ActionResult<SupplementResponse>> GetById(int id)
            => base.GetById(id);

        [Authorize(Roles ="Admin,GymMember")] 
        [HttpGet("{id}/reviews")]
        public async Task<ActionResult<IEnumerable<SupplementReviewResponse>>> GetReviews(int id)
        {
            var result = await _supplementService.GetReviewsAsync(id);
            return Ok(result);
        }
    }
}
