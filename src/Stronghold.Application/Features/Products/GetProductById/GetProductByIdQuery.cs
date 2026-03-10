using MediatR;

namespace Stronghold.Application.Features.Products.GetProductById;

public class GetProductByIdQuery : IRequest<ProductResponse>
{
    public int Id { get; set; }
}
