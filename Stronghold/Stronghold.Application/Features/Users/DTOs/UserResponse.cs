using Stronghold.Core.Enums;

namespace Stronghold.Application.Features.Users.DTOs;

public class UserResponse
{
    public int Id { get; set; }

public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string Username { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
    public Gender Gender { get; set; }

public string? ProfileImageUrl { get; set; }
}
