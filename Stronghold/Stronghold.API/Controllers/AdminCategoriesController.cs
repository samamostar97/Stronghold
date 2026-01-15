using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.AdminCategoriesDTO;
using Stronghold.Application.Filters;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/admin/categories")]
    public class AdminCategoriesController:BaseController<SupplementCategory,CategoryDTO,CreateCategoryDTO,UpdateCategoriesDTO,CategoryQueryFilter,int>
    {

        public AdminCategoriesController(IAdminCategoryService service) : base(service)
        {
        }
    }
}
