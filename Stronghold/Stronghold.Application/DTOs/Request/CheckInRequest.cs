using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Request
{
    public class CheckInRequest
    {
        [Range(1, int.MaxValue, ErrorMessage = "Korisnik je obavezan.")]
        public int UserId { get; set; }
    }
}
