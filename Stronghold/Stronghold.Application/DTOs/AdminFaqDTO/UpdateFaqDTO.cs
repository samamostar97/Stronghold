using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.AdminFaqDTO
{
    public class UpdateFaqDTO
    {
        [StringLength(500, MinimumLength = 2, ErrorMessage = "Pitanje mora imati između 2 i 500 karaktera.")]
        public string? Question { get; set; }

        [StringLength(2000, MinimumLength = 2, ErrorMessage = "Odgovor mora imati između 2 i 2000 karaktera.")]
        public string? Answer { get; set; }
    }
}
