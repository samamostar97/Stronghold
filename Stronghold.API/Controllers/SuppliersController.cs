using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.Suppliers;
using Stronghold.Application.Interfaces;
using Stronghold.Core;

namespace Stronghold.API.Controllers;

[Route("api/suppliers")]
[Authorize(Roles = Roles.Admin)]
public class SuppliersController : BaseCrudController<SupplierResponse, SupplierSearch,
    SupplierUpsertRequest, SupplierUpsertRequest>
{
    public SuppliersController(ISupplierService service) : base(service)
    {
    }
}
