using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Filters;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/membership-packages")]
    public class MembershipPackageController : BaseController<MembershipPackage, MembershipPackageResponse, CreateMembershipPackageRequest, UpdateMembershipPackageRequest, MembershipPackageQueryFilter, int>
    {
        public MembershipPackageController(IMembershipPackageService service) : base(service)
        {
        }

        [Authorize(Roles ="Admin,GymMember")]
        [HttpGet("GetAllPaged")]
        public override async Task<ActionResult<PagedResult<MembershipPackageResponse>>> GetAllPagedAsync([FromQuery] MembershipPackageQueryFilter filter)
        {
            return await base.GetAllPagedAsync(filter);
        }

        [Authorize(Roles ="Admin,GymMember")]
        [HttpGet("GetAll")]
        public override async Task<ActionResult<IEnumerable<MembershipPackageResponse>>> GetAllAsync([FromQuery] MembershipPackageQueryFilter filter)
        {
            return await base.GetAllAsync(filter);
        }

        [Authorize(Roles ="Admin,GymMember")]
        [HttpGet("{id}")]
        public override async Task<ActionResult<MembershipPackageResponse>> GetById(int id)
        {
            return await base.GetById(id);
        }
    }
}
