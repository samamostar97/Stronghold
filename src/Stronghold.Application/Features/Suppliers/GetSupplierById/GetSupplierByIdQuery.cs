using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Suppliers.GetSupplierById;

[AuthorizeRole("Admin")]
public class GetSupplierByIdQuery : IRequest<SupplierResponse>
{
    public int Id { get; set; }
}
