using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Products.GetProductById;

[AuthorizeRole("Admin")]
[AuthorizeRole("User")]
public class GetProductByIdQuery : IRequest<ProductResponse>
{
    public int Id { get; set; }
}
