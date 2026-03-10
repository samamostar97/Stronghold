using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.ProductCategories.DeleteProductCategory;

[AuthorizeRole("Admin")]
public class DeleteProductCategoryCommand : IRequest<Unit>
{
    public int Id { get; set; }
}
