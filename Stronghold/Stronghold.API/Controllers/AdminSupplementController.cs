using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.AdminSupplementsDTO;
using Stronghold.Application.Filters;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/admin/supplements")]
    [Authorize(Roles ="Admin")]
    public class AdminSupplementController : BaseController<Supplement, SupplementDTO, CreateSupplementDTO, UpdateSupplementDTO, SupplementQueryFilter, int>
    {
        public AdminSupplementController(IAdminSupplementService service) : base(service)
        {
        }
    }
}
