using Stronghold.Application.Common;

namespace Stronghold.Application.DTOs.Users;

public class UserSearch : BaseSearchObject
{
    // Pretraga po imenu, prezimenu ili korisnickom imenu.
    public string? Text { get; set; }
}
