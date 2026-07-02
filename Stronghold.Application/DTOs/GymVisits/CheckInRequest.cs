using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.GymVisits;

public class CheckInRequest
{
    [Range(1, int.MaxValue, ErrorMessage = "Odaberite korisnika.")]
    public int UserId { get; set; }
}
