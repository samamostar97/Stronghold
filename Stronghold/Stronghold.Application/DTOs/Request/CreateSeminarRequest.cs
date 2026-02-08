using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Request
{
    public class CreateSeminarRequest
    {
        [Required(ErrorMessage = "Tema seminara je obavezna.")]
        [StringLength(100, MinimumLength = 2, ErrorMessage = "Tema mora imati između 2 i 100 karaktera.")]
        public string Topic { get; set; } = string.Empty;

        [Required(ErrorMessage = "Ime govornika je obavezno.")]
        [StringLength(100, MinimumLength = 2, ErrorMessage = "Ime govornika mora imati između 2 i 100 karaktera.")]
        public string SpeakerName { get; set; } = string.Empty;

        [Required(ErrorMessage = "Datum seminara je obavezan.")]
        public DateTime EventDate { get; set; }
    }
}
