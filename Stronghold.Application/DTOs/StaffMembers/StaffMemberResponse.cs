namespace Stronghold.Application.DTOs.StaffMembers;

public class StaffMemberResponse
{
    public int Id { get; set; }
    public string FirstName { get; set; } = null!;
    public string LastName { get; set; } = null!;
    public string StaffType { get; set; } = null!;
    public string Biography { get; set; } = null!;
    public string Email { get; set; } = null!;
    public string Phone { get; set; } = null!;
    public int WorkStartHour { get; set; }
    public int WorkEndHour { get; set; }
    public bool HasImage { get; set; }
}
