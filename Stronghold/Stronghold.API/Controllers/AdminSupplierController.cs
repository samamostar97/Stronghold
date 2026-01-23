using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.AdminSupplierDTO;
using Stronghold.Application.Filters;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/admin/supplier")]
    [Authorize(Roles ="Admin")]
    public class AdminSupplierController : BaseController<Supplier, SupplierDTO, CreateSupplierDTO, UpdateSupplierDTO, SupplierQueryFilter, int>
    {
        public AdminSupplierController(IAdminSupplierService service) : base(service)
        {
        }

    }
}
