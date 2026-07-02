using Stronghold.Application.Common;

namespace Stronghold.Application.DTOs.Memberships;

public class MembershipSearch : BaseSearchObject
{
    public int? UserId { get; set; }
    /// <summary>Pretraga po imenu, prezimenu ili korisnickom imenu clana.</summary>
    public string? Text { get; set; }
    public bool? OnlyActive { get; set; }
}
