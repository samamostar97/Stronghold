using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.Seminars;
using Stronghold.Application.Interfaces;
using Stronghold.Core;

namespace Stronghold.API.Controllers;

/// <summary>
/// Citanje i prijava su dostupni clanovima (mobile), CRUD i pregled ucesnika adminu.
/// </summary>
[Route("api/seminars")]
public class SeminarsController : BaseCrudController<SeminarResponse, SeminarSearch,
    SeminarUpsertRequest, SeminarUpsertRequest>
{
    private readonly ISeminarService _seminarService;

    public SeminarsController(ISeminarService seminarService) : base(seminarService)
    {
        _seminarService = seminarService;
    }

    [Authorize(Roles = Roles.Admin)]
    public override Task<ActionResult<SeminarResponse>> Insert(SeminarUpsertRequest request)
        => base.Insert(request);

    [Authorize(Roles = Roles.Admin)]
    public override Task<ActionResult<SeminarResponse>> Update(int id, SeminarUpsertRequest request)
        => base.Update(id, request);

    [Authorize(Roles = Roles.Admin)]
    public override Task<IActionResult> Delete(int id)
        => base.Delete(id);

    /// <summary>Prijava jednim klikom - korisnik iz JWT tokena.</summary>
    [HttpPost("{id}/register")]
    [Authorize(Roles = Roles.GymMember)]
    public async Task<ActionResult<SeminarResponse>> Register(int id)
    {
        return Ok(await _seminarService.RegisterAsync(id));
    }

    /// <summary>Odjava oslobadja mjesto - moguca do pocetka seminara.</summary>
    [HttpPost("{id}/unregister")]
    [Authorize(Roles = Roles.GymMember)]
    public async Task<ActionResult<SeminarResponse>> Unregister(int id)
    {
        return Ok(await _seminarService.UnregisterAsync(id));
    }

    /// <summary>Otkaz seminara - svi prijavljeni dobijaju notifikaciju i e-mail.</summary>
    [HttpPut("{id}/cancel")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<ActionResult<SeminarResponse>> Cancel(int id, SeminarCancelRequest request)
    {
        return Ok(await _seminarService.CancelAsync(id, request));
    }

    [HttpGet("{id}/registrations")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<ActionResult<List<SeminarRegistrationResponse>>> GetRegistrations(int id)
    {
        return Ok(await _seminarService.GetRegistrationsAsync(id));
    }
}
