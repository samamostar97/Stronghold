using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Suppliers.DeleteSupplier;

[AuthorizeRole("Admin")]
public class DeleteSupplierCommand : IRequest<Unit>
{
    public int Id { get; set; }
}
