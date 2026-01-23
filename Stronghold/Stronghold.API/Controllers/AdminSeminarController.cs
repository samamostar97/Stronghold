using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.AdminSeminarDTO;
using Stronghold.Application.Filters;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/admin/seminar")]
    [Authorize(Roles ="Admin")]
    public class AdminSeminarController : BaseController<Seminar, SeminarDTO, CreateSeminarDTO, UpdateSeminarDTO, SeminarQueryFilter, int>
    {
        public AdminSeminarController(IAdminSeminarService service) : base(service)
        {
        }
    }
}
