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
    [Route("api/supplement-categories")]
    public class SupplementCategoryController : BaseController<SupplementCategory, SupplementCategoryResponse, CreateSupplementCategoryRequest, UpdateSupplementCategoryRequest, SupplementCategoryQueryFilter, int>
    {
        public SupplementCategoryController(ISupplementCategoryService service) : base(service)
        {
        }

        [Authorize(Roles ="Admin,GymMember")] 
        [HttpGet("GetAllPaged")]
        public override Task<ActionResult<PagedResult<SupplementCategoryResponse>>> GetAllPagedAsync([FromQuery] SupplementCategoryQueryFilter filter)
            => base.GetAllPagedAsync(filter);
        
        [Authorize(Roles ="Admin,GymMember")] 
        [HttpGet("GetAll")]
        public override Task<ActionResult<IEnumerable<SupplementCategoryResponse>>> GetAllAsync([FromQuery] SupplementCategoryQueryFilter filter)
            => base.GetAllAsync(filter);
        [Authorize(Roles = "Admin,GymMember")]
        [HttpGet("{id}")]
        public override Task<ActionResult<SupplementCategoryResponse>> GetById(int id)
        {
            return base.GetById(id);
        }
        [Authorize(Roles ="Admin")] 
        [HttpPost]
        public override Task<ActionResult<SupplementCategoryResponse>> Create([FromBody] CreateSupplementCategoryRequest dto)
        {
            return base.Create(dto);
        }
        [Authorize(Roles ="Admin")] 
        [HttpPut("{id}")]
        public override Task<ActionResult<SupplementCategoryResponse>> Update(int id, [FromBody] UpdateSupplementCategoryRequest dto)
        {
            return base.Update(id, dto);
        }
        [Authorize(Roles ="Admin")] 
        [HttpDelete("{id}")]
        public override Task<IActionResult> Delete(int id)
        {
            return base.Delete(id);
        }
        
    }
}
