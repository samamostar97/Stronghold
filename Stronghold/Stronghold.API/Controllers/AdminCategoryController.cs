using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.AdminCategoryDTO;
using Stronghold.Application.Filters;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/admin/supplement-category")]
    [Authorize(Roles ="Admin")]
    public class AdminCategoryController : BaseController<SupplementCategory, SupplementCategoryDTO, CreateSupplementCategoryDTO, UpdateSupplementCategoryDTO, SupplementCategoryQueryFilter, int>
    {
        public AdminCategoryController(IAdminCategoryService service) : base(service)
        {
        }
    }
}
