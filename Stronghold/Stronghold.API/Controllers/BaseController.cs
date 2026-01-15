using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.IServices;

namespace Stronghold.API.Controllers
{
    [Route("[controller]")]
    public class BaseController<T, TDto, TCreateDto, TUpdateDto, TQueryFilter, TKey> : ControllerBase
        where T : class
        where TDto : class
        where TCreateDto : class
        where TUpdateDto : class
        where TQueryFilter : class
    {
        private readonly IBaseService<T, TDto, TCreateDto, TUpdateDto, TQueryFilter, TKey> _service;

        public BaseController(IBaseService<T, TDto, TCreateDto, TUpdateDto, TQueryFilter, TKey> service)
        {
            _service = service;
        }
        [HttpGet("{id}")]
        public virtual async Task<ActionResult<TDto>> GetById(TKey id)
        {
            var result = await _service.GetByIdAsync(id);
            return Ok(result);
        }

        [HttpGet]
        public virtual async Task<ActionResult> GetAll([FromQuery] TQueryFilter? queryFilter = null)
        {
            var result = await _service.GetAllAsync(queryFilter);
            return Ok(result);
        }

        [HttpPost]
        public virtual async Task<ActionResult<TDto>> Create([FromBody] TCreateDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var result = await _service.CreateAsync(dto);

            // Extract the Id from the returned DTO
            var idProperty = result?.GetType().GetProperty("Id");
            var id = idProperty?.GetValue(result);

            return CreatedAtAction(nameof(GetById), new { id }, new { id });
        }

        [HttpPut("{id}")]
        public virtual async Task<ActionResult> Update(TKey id, [FromBody] TUpdateDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var ok = await _service.UpdateAsync(id, dto);
            if (ok == null)
                return NotFound();
            return NoContent();
        }

        [HttpDelete("{id}")]
        public virtual async Task<IActionResult> Delete(TKey id)
        {
            await _service.DeleteAsync(id);
            return NoContent();
        }

    }
}
