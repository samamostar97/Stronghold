using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Products.UpdateProduct;

[AuthorizeRole("Admin")]
public class UpdateProductCommand : IRequest<ProductResponse>
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public decimal Price { get; set; }
    public int StockQuantity { get; set; }
    public int CategoryId { get; set; }
    public int SupplierId { get; set; }
}
