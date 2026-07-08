using Stronghold.Core.Enums;

namespace Stronghold.Core.Entities;

public class User : BaseEntity
{
    public string FirstName { get; set; } = null!;
    public string LastName { get; set; } = null!;
    public string Username { get; set; } = null!;
    public string Email { get; set; } = null!;
    public string Phone { get; set; } = null!;
    public byte[]? ImageData { get; set; }
    public string PasswordHash { get; set; } = null!;
    public string PasswordSalt { get; set; } = null!;
    public UserRole Role { get; set; }
    public string? StreetAddress { get; set; }
    public int? CityId { get; set; }
    public City? City { get; set; }
    public DateTime CreatedAt { get; set; }

    public ICollection<RefreshToken> RefreshTokens { get; set; } = new List<RefreshToken>();
    public ICollection<Membership> Memberships { get; set; } = new List<Membership>();
    public ICollection<GymVisit> GymVisits { get; set; } = new List<GymVisit>();
    public ICollection<Order> Orders { get; set; } = new List<Order>();
    public ICollection<Appointment> Appointments { get; set; } = new List<Appointment>();
    public ICollection<SeminarRegistration> SeminarRegistrations { get; set; } = new List<SeminarRegistration>();
    public ICollection<Review> Reviews { get; set; } = new List<Review>();
    public ICollection<Notification> Notifications { get; set; } = new List<Notification>();
    public ICollection<CartItem> CartItems { get; set; } = new List<CartItem>();
}
