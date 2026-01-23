using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.AdminTrainerDTO;
using Stronghold.Application.Filters;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/admin/trainer")]
    [Authorize(Roles ="Admin")]
    public class AdminTrainerController : BaseController<Trainer, TrainerDTO, CreateTrainerDTO, UpdateTrainerDTO, TrainerQueryFilter, int>
    {
        public AdminTrainerController(IAdminTrainerService service) : base(service)
        {
        }
    }
}
