using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.AdminNutritionistDTO;
using Stronghold.Application.Filters;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/admin/nutritionist")]
    [Authorize(Roles ="Admin")]
    public class AdminNutritionistController : BaseController<Nutritionist, NutritionistDTO, CreateNutritionistDTO, UpdateNutritionistDTO, NutritionistQueryFilter, int>
    {
        public AdminNutritionistController(IAdminNutritionistService service) : base(service)
        {
        }
    }
}
