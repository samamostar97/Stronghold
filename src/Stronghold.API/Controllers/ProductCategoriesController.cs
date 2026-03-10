using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Features.ProductCategories.CreateProductCategory;
using Stronghold.Application.Features.ProductCategories.DeleteProductCategory;
using Stronghold.Application.Features.ProductCategories.GetProductCategories;
using Stronghold.Application.Features.ProductCategories.GetProductCategoryById;
using Stronghold.Application.Features.ProductCategories.UpdateProductCategory;

namespace Stronghold.API.Controllers;

[ApiController]
[Authorize]
[Route("api/product-categories")]
public class ProductCategoriesController : ControllerBase
{
    private readonly IMediator _mediator;

    public ProductCategoriesController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<IActionResult> GetProductCategories()
    {
        var result = await _mediator.Send(new GetProductCategoriesQuery());
        return Ok(result);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetProductCategoryById(int id)
    {
        var result = await _mediator.Send(new GetProductCategoryByIdQuery { Id = id });
        return Ok(result);
    }

    [HttpPost]
    public async Task<IActionResult> CreateProductCategory([FromBody] CreateProductCategoryCommand command)
    {
        var result = await _mediator.Send(command);
        return StatusCode(201, result);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> UpdateProductCategory(int id, [FromBody] UpdateProductCategoryCommand command)
    {
        command.Id = id;
        var result = await _mediator.Send(command);
        return Ok(result);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> DeleteProductCategory(int id)
    {
        await _mediator.Send(new DeleteProductCategoryCommand { Id = id });
        return NoContent();
    }
}
