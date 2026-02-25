using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Appointments.DTOs;

public class AppointmentFilter : PaginationRequest
{
    public string? OrderBy { get; set; }

public string? Search { get; set; }
}
