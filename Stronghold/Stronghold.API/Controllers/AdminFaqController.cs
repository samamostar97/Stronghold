using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.AdminFaqDTO;
using Stronghold.Application.Filters;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/admin/faq")]
    [Authorize(Roles ="Admin")]
    public class AdminFaqController : BaseController<FAQ, FaqDTO, CreateFaqDTO, UpdateFaqDTO, FaqQueryFilter, int>
    {
        public AdminFaqController(IAdminFaqService service) : base(service)
        {
        }
    }
}
