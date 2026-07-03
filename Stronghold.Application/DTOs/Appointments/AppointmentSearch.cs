using Stronghold.Application.Common;
using Stronghold.Core.Enums;

namespace Stronghold.Application.DTOs.Appointments;

public class AppointmentSearch : BaseSearchObject
{
    public DateOnly? Date { get; set; }
    public AppointmentStatus? Status { get; set; }
    public int? StaffMemberId { get; set; }
    /// <summary>Pretraga po imenu, prezimenu ili korisnickom imenu clana.</summary>
    public string? Text { get; set; }
}
