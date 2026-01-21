using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.AdminPackageDTO;
using Stronghold.Application.Filters;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/admin/membership-package")]
    [Authorize(Roles ="Admin")]
    public class AdminPackageController : BaseController<MembershipPackage, MembershipPackageDTO, CreateMembershipPackageDTO, UpdateMembershipPackageDTO, MembershipPackageQueryFilter, int>
    {
        public AdminPackageController(IAdminPackageService service) : base(service)
        {
        }
    }
}
