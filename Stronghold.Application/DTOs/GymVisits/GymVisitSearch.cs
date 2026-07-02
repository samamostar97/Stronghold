using Stronghold.Application.Common;

namespace Stronghold.Application.DTOs.GymVisits;

public class GymVisitSearch : BaseSearchObject
{
    public int? UserId { get; set; }
    public DateTime? From { get; set; }
    public DateTime? To { get; set; }
    /// <summary>Samo posjete bez check-outa (trenutno u teretani).</summary>
    public bool? OnlyInGym { get; set; }
}
