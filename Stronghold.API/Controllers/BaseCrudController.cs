using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.Interfaces;

namespace Stronghold.API.Controllers;

/// <summary>
/// Genericki CRUD kontroler - bez poslovne logike, samo delegira servisu.
/// Akcije su virtualne da izvedeni kontroleri mogu pooštriti autorizaciju po roli.
/// </summary>
[ApiController]
[Authorize]
public abstract class BaseCrudController<TResponse, TSearch, TInsert, TUpdate> : ControllerBase
    where TSearch : BaseSearchObject
{
    protected readonly ICrudService<TResponse, TSearch, TInsert, TUpdate> Service;

    protected BaseCrudController(ICrudService<TResponse, TSearch, TInsert, TUpdate> service)
    {
        Service = service;
    }

    [HttpGet]
    public virtual async Task<ActionResult<PagedResult<TResponse>>> GetPaged([FromQuery] TSearch search)
    {
        return Ok(await Service.GetPagedAsync(search));
    }

    [HttpGet("{id}")]
    public virtual async Task<ActionResult<TResponse>> GetById(int id)
    {
        return Ok(await Service.GetByIdAsync(id));
    }

    [HttpPost]
    public virtual async Task<ActionResult<TResponse>> Insert(TInsert request)
    {
        return Ok(await Service.InsertAsync(request));
    }

    [HttpPut("{id}")]
    public virtual async Task<ActionResult<TResponse>> Update(int id, TUpdate request)
    {
        return Ok(await Service.UpdateAsync(id, request));
    }

    [HttpDelete("{id}")]
    public virtual async Task<IActionResult> Delete(int id)
    {
        await Service.DeleteAsync(id);
        return NoContent();
    }
}
