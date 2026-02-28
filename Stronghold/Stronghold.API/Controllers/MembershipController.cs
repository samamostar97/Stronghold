using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Memberships.Commands;
using Stronghold.Application.Features.Memberships.DTOs;
using Stronghold.Application.Features.Memberships.Queries;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/memberships")]
    [Authorize]
    public class MembershipController: ControllerBase
    {
        private readonly IMediator _mediator;

        public MembershipController(IMediator mediator)
        {
            _mediator = mediator;
        }
        [HttpPost]
        public async Task<ActionResult<MembershipResponse>> AssignMembershipAsync([FromBody] AssignMembershipCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }
        [HttpDelete("{userId:int}")]
        public async Task<IActionResult> RevokeMembershipAsync(int userId)
        {
            await _mediator.Send(new RevokeMembershipCommand { UserId = userId });
            return NoContent();
        }
        [HttpGet("{userId:int}/is-active")]
        public async Task<ActionResult<bool>> HasActiveMembership(int userId)
        {
            var result = await _mediator.Send(new HasActiveMembershipQuery { UserId = userId });
            return Ok(result);
        }
        [HttpGet("{userId:int}/history")]
        public async Task<ActionResult<PagedResult<MembershipPaymentResponse>>> GetPayments(int userId, [FromQuery] MembershipPaymentFilter filter)
        {
            var result = await _mediator.Send(new GetMembershipPaymentsQuery
            {
                UserId = userId,
                Filter = filter
            });
            return Ok(result);
        }

        [HttpGet("payments")]
        public async Task<ActionResult<PagedResult<AdminMembershipPaymentResponse>>> GetAllPayments([FromQuery] AdminMembershipPaymentsFilter filter)
        {
            var result = await _mediator.Send(new GetAllMembershipPaymentsQuery
            {
                Filter = filter
            });
            return Ok(result);
        }

        [HttpGet("active-members")]
        public async Task<ActionResult<PagedResult<ActiveMemberResponse>>> GetActiveMembers([FromQuery] ActiveMemberFilter filter)
        {
            var result = await _mediator.Send(new GetActiveMembersQuery { Filter = filter });
            return Ok(result);
        }
    }
}
