using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Memberships;

public class MembershipAssignRequest
{
    [Range(1, int.MaxValue, ErrorMessage = "Odaberite korisnika.")]
    public int UserId { get; set; }

    [Range(1, int.MaxValue, ErrorMessage = "Odaberite paket članarine.")]
    public int PackageId { get; set; }
}
