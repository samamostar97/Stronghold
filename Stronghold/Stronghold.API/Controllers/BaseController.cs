using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.API.Controllers
{
    [Route("[controller]")]
    public class BaseController<T, TDto, TCreateDto, TUpdateDto, TQueryFilter, TKey> : ControllerBase
        where T : class
    {
        protected readonly IService<T, TDto, TCreateDto, TUpdateDto, TQueryFilter, TKey> _service;
        public BaseController(IService<T, TDto, TCreateDto, TUpdateDto, TQueryFilter, TKey> service)
        {
            _service = service;
        }
        [HttpGet("GetAllPaged")]
        public virtual async Task<ActionResult<PagedResult<TDto>>> GetAllPagedAsync([FromQuery]PaginationRequest request, [FromQuery]TQueryFilter? filter)
        {
            var list = await _service.GetPagedAsync(request, filter);
            return Ok(list);
        }
        [HttpGet("GetAll")]
        public virtual async Task<ActionResult<IEnumerable<TDto>>> GetAllAsync([FromQuery]TQueryFilter? filter)
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

            return CreatedAtAction(nameof(GetById), new { id }, new { id });
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
            
            return NoContent();
        }
    }
}
