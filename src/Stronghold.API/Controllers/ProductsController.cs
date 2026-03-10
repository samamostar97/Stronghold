using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Features.Products.CreateProduct;
using Stronghold.Application.Features.Products.DeleteProduct;
using Stronghold.Application.Features.Products.GetProductById;
using Stronghold.Application.Features.Products.GetProducts;
using Stronghold.Application.Features.Products.UpdateProduct;
using Stronghold.Application.Features.Products.GetRecommendations;
using Stronghold.Application.Features.Products.UpdateProductImage;

namespace Stronghold.API.Controllers;

[ApiController]
[Authorize]
[Route("api/products")]
public class ProductsController : ControllerBase
{
    private readonly IMediator _mediator;

    public ProductsController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<IActionResult> GetProducts([FromQuery] GetProductsQuery query)
    {
        var result = await _mediator.Send(query);
        return Ok(result);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetProductById(int id)
    {
        var result = await _mediator.Send(new GetProductByIdQuery { Id = id });
        return Ok(result);
    }

    [HttpPost]
    public async Task<IActionResult> CreateProduct([FromBody] CreateProductCommand command)
    {
        var result = await _mediator.Send(command);
        return StatusCode(201, result);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> UpdateProduct(int id, [FromBody] UpdateProductCommand command)
    {
        command.Id = id;
        var result = await _mediator.Send(command);
        return Ok(result);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> DeleteProduct(int id)
    {
        await _mediator.Send(new DeleteProductCommand { Id = id });
        return NoContent();
    }

    [HttpGet("recommendations")]
    public async Task<IActionResult> GetRecommendations()
    {
        var result = await _mediator.Send(new GetRecommendationsQuery());
        return Ok(result);
    }

    [HttpPut("{id:int}/image")]
    public async Task<IActionResult> UpdateProductImage(int id, IFormFile file)
    {
        var command = new UpdateProductImageCommand
        {
            Id = id,
            FileStream = file.OpenReadStream(),
            FileName = file.FileName
        };

        var result = await _mediator.Send(command);
        return Ok(result);
    }
}
