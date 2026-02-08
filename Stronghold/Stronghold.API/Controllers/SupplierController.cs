using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Filters;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/suppliers")]
    [Authorize(Roles ="Admin")]
    public class SupplierController : BaseController<Supplier, SupplierResponse, CreateSupplierRequest, UpdateSupplierRequest, SupplierQueryFilter, int>
    {
        public SupplierController(ISupplierService service) : base(service)
        {
        }

    }
}
