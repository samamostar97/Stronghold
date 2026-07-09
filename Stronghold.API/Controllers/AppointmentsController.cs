using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Appointments;
using Stronghold.Application.Interfaces;
using Stronghold.Core;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/appointments")]
[Authorize]
public class AppointmentsController : ControllerBase
{
    private readonly IAppointmentService _appointmentService;

    public AppointmentsController(IAppointmentService appointmentService)
    {
        _appointmentService = appointmentService;
    }

    [HttpGet]
    [Authorize(Roles = Roles.Admin)]
    public async Task<ActionResult<PagedResult<AppointmentResponse>>> GetPaged([FromQuery] AppointmentSearch search)
    {
        return Ok(await _appointmentService.GetPagedAsync(search));
    }

    [HttpGet("{id}")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<ActionResult<AppointmentResponse>> GetById(int id)
    {
        return Ok(await _appointmentService.GetByIdAsync(id));
    }

    /// <summary>Slobodne satnice za odabranu osobu i datum (dropdown filtrira zauzete).</summary>
    [HttpGet("free-slots")]
    public async Task<ActionResult<List<int>>> GetFreeSlots(
        [FromQuery] int staffMemberId, [FromQuery] DateOnly date)
    {
        return Ok(await _appointmentService.GetFreeSlotsAsync(staffMemberId, date));
    }

    /// <summary>Mobile booking - korisnik iz JWT tokena.</summary>
    [HttpPost("my")]
    [Authorize(Roles = Roles.GymMember)]
    public async Task<ActionResult<AppointmentResponse>> CreateMine(AppointmentCreateRequest request)
    {
        return Ok(await _appointmentService.CreateMineAsync(request));
    }

    [HttpGet("my")]
    [Authorize(Roles = Roles.GymMember)]
    public async Task<ActionResult<PagedResult<AppointmentResponse>>> GetMine([FromQuery] BaseSearchObject search)
    {
        return Ok(await _appointmentService.GetMineAsync(search));
    }

    /// <summary>Desktop - admin direktno dodaje termin.</summary>
    [HttpPost]
    [Authorize(Roles = Roles.Admin)]
    public async Task<ActionResult<AppointmentResponse>> Create(AdminAppointmentCreateRequest request)
    {
        return Ok(await _appointmentService.CreateAsync(request));
    }

    [HttpPut("{id}/confirm")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<ActionResult<AppointmentResponse>> Confirm(int id)
    {
        return Ok(await _appointmentService.ConfirmAsync(id));
    }

    [HttpPut("{id}/complete")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<ActionResult<AppointmentResponse>> Complete(int id)
    {
        return Ok(await _appointmentService.CompleteAsync(id));
    }

    /// <summary>Evidencija nedolaska - dostupno tek kad termin prodje.</summary>
    [HttpPut("{id}/no-show")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<ActionResult<AppointmentResponse>> MarkNoShow(int id)
    {
        return Ok(await _appointmentService.MarkNoShowAsync(id));
    }

    /// <summary>Otkazivanje je omoguceno i clanu (vlastiti termin) i adminu.</summary>
    [HttpPut("{id}/cancel")]
    public async Task<ActionResult<AppointmentResponse>> Cancel(int id, AppointmentCancelRequest request)
    {
        return Ok(await _appointmentService.CancelAsync(id, request));
    }
}
