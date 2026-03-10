using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Suppliers.GetSuppliers;

[AuthorizeRole("Admin")]
public class GetSuppliersQuery : BaseQueryFilter, IRequest<PagedResult<SupplierResponse>>
{
}
