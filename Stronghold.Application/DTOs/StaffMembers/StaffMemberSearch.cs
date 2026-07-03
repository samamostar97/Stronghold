using Stronghold.Application.Common;
using Stronghold.Core.Enums;

namespace Stronghold.Application.DTOs.StaffMembers;

public class StaffMemberSearch : BaseSearchObject
{
    /// <summary>Pretraga po imenu ili prezimenu.</summary>
    public string? Text { get; set; }

    /// <summary>UI prikazuje trenere i nutricioniste kao odvojene ekrane - filter po tipu.</summary>
    public StaffType? StaffType { get; set; }
}
