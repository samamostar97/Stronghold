using Stronghold.Application.Common;
using Stronghold.Core.Enums;

namespace Stronghold.Application.DTOs.StaffMembers;

public class StaffMemberSearch : BaseSearchObject
{
    // Pretraga po imenu ili prezimenu.
    public string? Text { get; set; }

    // UI prikazuje trenere i nutricioniste kao odvojene ekrane - filter po tipu.
    public StaffType? StaffType { get; set; }
}
