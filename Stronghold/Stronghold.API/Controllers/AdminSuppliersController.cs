using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.AdminSuppliersDTO;
using Stronghold.Application.Filters;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/admin/suppliers")]
    public class AdminSuppliersController : BaseController<Supplier, SupplierDTO, CreateSupplierDTO, UpdateSupplierDTO, SupplierQueryFilter, int>
    {
        public AdminSuppliersController(IAdminSupplierService service) : base(service)
        {
        }
    }
}
