using Stronghold.Application.Common;

namespace Stronghold.Application.DTOs.GymVisits;

public class GymVisitSearch : BaseSearchObject
{
    public int? UserId { get; set; }
    public DateTime? From { get; set; }
    public DateTime? To { get; set; }
    // Samo posjete bez check-outa (trenutno u teretani).
    public bool? OnlyInGym { get; set; }
}
