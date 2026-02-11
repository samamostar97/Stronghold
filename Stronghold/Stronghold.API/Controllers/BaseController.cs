using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.DependencyInjection;
using System.Security.Claims;
using Stronghold.Application.Common;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.API.Controllers
{
    [Authorize]
    [Route("[controller]")]
    public class BaseController<T, TDto, TCreateDto, TUpdateDto, TQueryFilter, TKey> : UserControllerBase
        where T : class
        where TQueryFilter : PaginationRequest, new()
    {
        protected readonly IService<T, TDto, TCreateDto, TUpdateDto, TQueryFilter, TKey> _service;

        public BaseController(IService<T, TDto, TCreateDto, TUpdateDto, TQueryFilter, TKey> service)
        {
            _service = service;
        }

        [HttpGet("GetAllPaged")]
        public virtual async Task<ActionResult<PagedResult<TDto>>> GetAllPagedAsync([FromQuery] TQueryFilter filter)
        {
            var list = await _service.GetPagedAsync(filter);
            return Ok(list);
        }

        [HttpGet("GetAll")]
        public virtual async Task<ActionResult<IEnumerable<TDto>>> GetAllAsync([FromQuery] TQueryFilter filter)
        {
            var list = await _service.GetAllAsync(filter);
            return Ok(list);
        }

        [HttpGet("{id}")]
        public virtual async Task<ActionResult<TDto>> GetById(TKey id)
        {
            var result = await _service.GetByIdAsync(id);
            return Ok(result);
        }

        [HttpPost]
        public virtual async Task<ActionResult<TDto>> Create([FromBody]TCreateDto dto)
        {
            var result = await _service.CreateAsync(dto);
            var idProp = result!.GetType().GetProperty("Id");
            var id = idProp?.GetValue(result);

            return CreatedAtAction(nameof(GetById), new { id }, result);
        }

        [HttpPut("{id}")]
        public virtual async Task<ActionResult<TDto>> Update(TKey id, [FromBody] TUpdateDto dto)
        {
            var result = await _service.UpdateAsync(id, dto);
            return Ok(result);
        }

        [HttpDelete("{id}")]
        public virtual async Task<IActionResult> Delete(TKey id)
        {
            await _service.DeleteAsync(id);

            if (User.IsInRole("Admin") && id is int entityId)
            {
                var adminUserId = GetCurrentUserId();
                if (adminUserId.HasValue)
                {
                    var adminUsername = User.FindFirst(ClaimTypes.Name)?.Value ?? "admin";
                    var activityService = HttpContext.RequestServices.GetService<IAdminActivityService>();
                    if (activityService != null)
                    {
                        await activityService.LogDeleteAsync(
                            adminUserId.Value,
                            adminUsername,
                            typeof(T).Name,
                            entityId);
                    }
                }
            }

            return NoContent();
        }
    }
}
