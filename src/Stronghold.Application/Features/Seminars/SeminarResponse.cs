namespace Stronghold.Application.Features.Seminars;

public class SeminarResponse
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Lecturer { get; set; } = string.Empty;
    public DateTime StartDate { get; set; }
    public int DurationMinutes { get; set; }
    public int MaxCapacity { get; set; }
    public int RegisteredCount { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class SeminarRegistrationResponse
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string UserFullName { get; set; } = string.Empty;
    public string UserEmail { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}
