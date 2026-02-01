using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.AdminVisitsDTO
{
    public class CheckInRequestDTO
    {
        [Range(1, int.MaxValue, ErrorMessage = "Korisnik je obavezan.")]
        public int UserId { get; set; }
    }
}
