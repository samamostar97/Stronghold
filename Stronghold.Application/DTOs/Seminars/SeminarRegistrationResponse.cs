namespace Stronghold.Application.DTOs.Seminars;

public class SeminarRegistrationResponse
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string UserFullName { get; set; } = null!;
    public string Username { get; set; } = null!;
    public DateTime RegisteredAt { get; set; }
}
