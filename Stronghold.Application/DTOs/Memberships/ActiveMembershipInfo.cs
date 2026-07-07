namespace Stronghold.Application.DTOs.Memberships;

// Trenutno aktivna clanarina clana - za upozorenje pri evidenciji nove uplate.
public class ActiveMembershipInfo
{
    public bool HasActive { get; set; }
    public string? PackageName { get; set; }
    public DateTime? EndDate { get; set; }
}
