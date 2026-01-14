using Stronghold.Core.Enums;

namespace Stronghold.Application.DTOs.AdminUsersDTO;

public class AdminUpdateUserDTO
{
    public string FirstName { get; set; } = "";
    public string LastName { get; set; } = "";
    public string Username { get; set; } = "";
    public string Email { get; set; } = "";
    public string PhoneNumber { get; set; } = "";
    public Gender Gender { get; set; }
    public Role Role { get; set; }
    public string? ProfileImageUrl { get; set; }
    public string? NewPassword { get; set; }
}
