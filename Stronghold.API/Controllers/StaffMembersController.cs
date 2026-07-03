using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.StaffMembers;
using Stronghold.Application.Interfaces;
using Stronghold.Core;

namespace Stronghold.API.Controllers;

/// <summary>
/// Citanje je dostupno svim prijavljenim korisnicima (mobile booking bira osoblje),
/// izmjene su samo za admina.
/// </summary>
[Route("api/staff-members")]
public class StaffMembersController : BaseCrudController<StaffMemberResponse, StaffMemberSearch,
    StaffMemberUpsertRequest, StaffMemberUpsertRequest>
{
    private readonly IStaffMemberService _staffMemberService;

    public StaffMembersController(IStaffMemberService staffMemberService) : base(staffMemberService)
    {
        _staffMemberService = staffMemberService;
    }

    [Authorize(Roles = Roles.Admin)]
    public override Task<ActionResult<StaffMemberResponse>> Insert(StaffMemberUpsertRequest request)
        => base.Insert(request);

    [Authorize(Roles = Roles.Admin)]
    public override Task<ActionResult<StaffMemberResponse>> Update(int id, StaffMemberUpsertRequest request)
        => base.Update(id, request);

    [Authorize(Roles = Roles.Admin)]
    public override Task<IActionResult> Delete(int id)
        => base.Delete(id);

    [HttpGet("{id}/image")]
    public async Task<IActionResult> GetImage(int id)
    {
        var (data, contentType) = await _staffMemberService.GetImageAsync(id);
        return File(data, contentType);
    }
}
