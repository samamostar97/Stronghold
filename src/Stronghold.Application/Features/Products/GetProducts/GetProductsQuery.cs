using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Products.GetProducts;

[AuthorizeRole("Admin")]
[AuthorizeRole("User")]
public class GetProductsQuery : BaseQueryFilter, IRequest<PagedResult<ProductResponse>>
{
    public int? CategoryId { get; set; }
    public int? SupplierId { get; set; }
    public decimal? MinPrice { get; set; }
    public decimal? MaxPrice { get; set; }
}
