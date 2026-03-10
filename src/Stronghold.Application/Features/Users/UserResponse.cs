namespace Stronghold.Application.Features.Users;

public class UserResponse
{
    public int Id { get; set; }
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string Username { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? Phone { get; set; }
    public string? Address { get; set; }
    public string? ProfileImageUrl { get; set; }
    public string Role { get; set; } = string.Empty;
    public int Level { get; set; }
    public int XP { get; set; }
    public int TotalGymMinutes { get; set; }
}
