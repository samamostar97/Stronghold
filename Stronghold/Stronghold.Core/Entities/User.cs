namespace Stronghold.Core.Entities;

using Stronghold.Core.Enums;

public class User : BaseEntity
{

    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string Username { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
    public Gender Gender { get; set; }
    public Role Role { get; set; }
    public string PasswordHash { get; set; } = string.Empty;
    public string? ProfileImageUrl { get; set; }

    // Navigation properties
    public ICollection<GymVisit> GymVisits { get; set; } = new List<GymVisit>();
    public ICollection<Membership> Memberships { get; set; } = new List<Membership>();
    public ICollection<MembershipPaymentHistory> MembershipPaymentHistory { get; set; } = new List<MembershipPaymentHistory>();
    public ICollection<Order> Orders { get; set; } = new List<Order>();
    public ICollection<Appointment> Appointments { get; set; } = new List<Appointment>();
    public ICollection<Review> Reviews { get; set; } = new List<Review>();
    public ICollection<SeminarAttendee> SeminarAttendees { get; set; } = new List<SeminarAttendee>();
}
