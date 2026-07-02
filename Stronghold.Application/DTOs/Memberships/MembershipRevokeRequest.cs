using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Memberships;

public class MembershipRevokeRequest
{
    [Required(ErrorMessage = "Unesite razlog ukidanja članarine.")]
    [MaxLength(300, ErrorMessage = "Razlog može imati najviše 300 znakova.")]
    public string Reason { get; set; } = null!;
}
