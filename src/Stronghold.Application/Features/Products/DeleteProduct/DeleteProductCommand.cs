using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Products.DeleteProduct;

[AuthorizeRole("Admin")]
public class DeleteProductCommand : IRequest<Unit>
{
    public int Id { get; set; }
}
