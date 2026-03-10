using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Products.CreateProduct;

[AuthorizeRole("Admin")]
public class CreateProductCommand : IRequest<ProductResponse>
{
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public decimal Price { get; set; }
    public int StockQuantity { get; set; }
    public int CategoryId { get; set; }
    public int SupplierId { get; set; }
}
