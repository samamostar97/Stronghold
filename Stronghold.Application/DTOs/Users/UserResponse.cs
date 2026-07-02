namespace Stronghold.Application.DTOs.Users;

public class UserResponse
{
    public int Id { get; set; }
    public string FirstName { get; set; } = null!;
    public string LastName { get; set; } = null!;
    public string Username { get; set; } = null!;
    public string Email { get; set; } = null!;
    public string Phone { get; set; } = null!;
    public string Role { get; set; } = null!;
    public string? StreetAddress { get; set; }
    public int? CityId { get; set; }
    public string? CityName { get; set; }
    public bool HasImage { get; set; }
    public DateTime CreatedAt { get; set; }
}
