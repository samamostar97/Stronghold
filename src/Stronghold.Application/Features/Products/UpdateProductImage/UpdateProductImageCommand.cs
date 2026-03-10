using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Products.UpdateProductImage;

[AuthorizeRole("Admin")]
public class UpdateProductImageCommand : IRequest<ProductResponse>
{
    public int Id { get; set; }
    public Stream FileStream { get; set; } = null!;
    public string FileName { get; set; } = string.Empty;
}
