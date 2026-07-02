using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.MembershipPackages;
using Stronghold.Application.Interfaces;
using Stronghold.Core;

namespace Stronghold.API.Controllers;

/// <summary>
/// Citanje je dostupno svim prijavljenim korisnicima (clanovi vide ponudu paketa),
/// izmjene su samo za admina.
/// </summary>
[Route("api/membership-packages")]
public class MembershipPackagesController : BaseCrudController<MembershipPackageResponse, MembershipPackageSearch,
    MembershipPackageUpsertRequest, MembershipPackageUpsertRequest>
{
    public MembershipPackagesController(IMembershipPackageService service) : base(service)
    {
    }

    [Authorize(Roles = Roles.Admin)]
    public override Task<ActionResult<MembershipPackageResponse>> Insert(MembershipPackageUpsertRequest request)
        => base.Insert(request);

    [Authorize(Roles = Roles.Admin)]
    public override Task<ActionResult<MembershipPackageResponse>> Update(int id, MembershipPackageUpsertRequest request)
        => base.Update(id, request);

    [Authorize(Roles = Roles.Admin)]
    public override Task<IActionResult> Delete(int id)
        => base.Delete(id);
}
