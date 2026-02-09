using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Request
{
    public class UpdateSeminarRequest
    {
        [StringLength(100, MinimumLength = 2, ErrorMessage = "Tema mora imati između 2 i 100 karaktera.")]
        public string? Topic { get; set; }

        [StringLength(100, MinimumLength = 2, ErrorMessage = "Ime govornika mora imati između 2 i 100 karaktera.")]
        public string? SpeakerName { get; set; }

        public DateTime? EventDate { get; set; }

        [Range(1, 10000, ErrorMessage = "Kapacitet mora biti između 1 i 10000.")]
        public int? MaxCapacity { get; set; }
    }
}
