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
    [Route("api/faq")]
    public class FaqController : BaseController<FAQ, FaqResponse, CreateFaqRequest, UpdateFaqRequest, FaqQueryFilter, int>
    {
        public FaqController(IFaqService service) : base(service)
        {
        }

        // Authenticated users can view FAQs
        [Authorize(Roles ="Admin,GymMember")]
        [HttpGet("GetAllPaged")]
        public override Task<ActionResult<PagedResult<FaqResponse>>> GetAllPagedAsync([FromQuery] FaqQueryFilter filter)
        {
            return base.GetAllPagedAsync(filter);
        }

        [Authorize(Roles ="Admin,GymMember")]
        [HttpGet("GetAll")]
        public override async Task<ActionResult<IEnumerable<FaqResponse>>> GetAllAsync([FromQuery] FaqQueryFilter filter)
        {
            return await base.GetAllAsync(filter);
        }

        [Authorize(Roles ="Admin,GymMember")]
        [HttpGet("{id}")]
        public override async Task<ActionResult<FaqResponse>> GetById(int id)
        {
            return await base.GetById(id);
        }

        // Admin-only endpoints
        [Authorize(Roles = "Admin")]
        [HttpPost]
        public override async Task<ActionResult<FaqResponse>> Create([FromBody] CreateFaqRequest dto)
        {
            return await base.Create(dto);
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}")]
        public override async Task<ActionResult<FaqResponse>> Update(int id, [FromBody] UpdateFaqRequest dto)
        {
            return await base.Update(id, dto);
        }

        [Authorize(Roles = "Admin")]
        [HttpDelete("{id}")]
        public override async Task<IActionResult> Delete(int id)
        {
            return await base.Delete(id);
        }
    }
}
