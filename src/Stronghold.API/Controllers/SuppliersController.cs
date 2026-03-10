using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Features.Suppliers.CreateSupplier;
using Stronghold.Application.Features.Suppliers.DeleteSupplier;
using Stronghold.Application.Features.Suppliers.GetSupplierById;
using Stronghold.Application.Features.Suppliers.GetSuppliers;
using Stronghold.Application.Features.Suppliers.UpdateSupplier;

namespace Stronghold.API.Controllers;

[ApiController]
[Authorize]
[Route("api/suppliers")]
public class SuppliersController : ControllerBase
{
    private readonly IMediator _mediator;

    public SuppliersController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<IActionResult> GetSuppliers([FromQuery] GetSuppliersQuery query)
    {
        var result = await _mediator.Send(query);
        return Ok(result);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetSupplierById(int id)
    {
        var result = await _mediator.Send(new GetSupplierByIdQuery { Id = id });
        return Ok(result);
    }

    [HttpPost]
    public async Task<IActionResult> CreateSupplier([FromBody] CreateSupplierCommand command)
    {
        var result = await _mediator.Send(command);
        return StatusCode(201, result);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> UpdateSupplier(int id, [FromBody] UpdateSupplierCommand command)
    {
        command.Id = id;
        var result = await _mediator.Send(command);
        return Ok(result);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> DeleteSupplier(int id)
    {
        await _mediator.Send(new DeleteSupplierCommand { Id = id });
        return NoContent();
    }
}
