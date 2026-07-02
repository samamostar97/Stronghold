using Stronghold.Application.Common;

namespace Stronghold.Application.DTOs.Memberships;

public class MembershipSearch : BaseSearchObject
{
    public int? UserId { get; set; }
    // Pretraga po imenu, prezimenu ili korisnickom imenu clana.
    public string? Text { get; set; }
    public bool? OnlyActive { get; set; }
}
