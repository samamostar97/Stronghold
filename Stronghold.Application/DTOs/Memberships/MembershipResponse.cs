namespace Stronghold.Application.DTOs.Memberships;

public class MembershipResponse
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string UserFullName { get; set; } = null!;
    public string Username { get; set; } = null!;
    public int PackageId { get; set; }
    public string PackageName { get; set; } = null!;
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public bool IsRevoked { get; set; }
    public DateTime? RevokedAt { get; set; }
    public string? RevocationReason { get; set; }
    /// <summary>Racuna se iz datuma i flaga ukinuta - ne pohranjuje se.</summary>
    public bool IsActive { get; set; }
}
