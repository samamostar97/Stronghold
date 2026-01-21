using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.AdminUsersDTO;
using Stronghold.Application.Filters;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/admin/user")]
    [Authorize(Roles ="Admin")]
    public class AdminUsersController : BaseController<User, UserDTO, CreateUserDTO, UpdateUserDTO, UserQueryFilter, int>
    {
        public AdminUsersController(IAdminUserService service) : base(service)
        {
        }
    }
}
