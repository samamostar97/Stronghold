using Stronghold.Application.Common;

namespace Stronghold.Application.DTOs.Users;

public class UserSearch : BaseSearchObject
{
    /// <summary>Pretraga po imenu, prezimenu ili korisnickom imenu.</summary>
    public string? Text { get; set; }
}
