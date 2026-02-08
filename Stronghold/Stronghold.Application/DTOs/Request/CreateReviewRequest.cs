using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Request
{
    public class CreateReviewRequest
    {
        // Set by controller from JWT - not from client
        public int UserId { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = "Suplement je obavezan.")]
        public int SupplementId { get; set; }

        [Range(1, 5, ErrorMessage = "Ocjena mora biti između 1 i 5.")]
        public int Rating { get; set; }

        [StringLength(1000, MinimumLength = 2, ErrorMessage = "Komentar mora imati između 2 i 1000 karaktera.")]
        public string? Comment { get; set; }
    }
}
