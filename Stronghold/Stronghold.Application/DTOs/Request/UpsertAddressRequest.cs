using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Request
{
    public class UpsertAddressRequest
    {
        [Required(ErrorMessage = "Ulica je obavezna.")]
        [MaxLength(200)]
        public string Street { get; set; } = string.Empty;

        [Required(ErrorMessage = "Grad je obavezan.")]
        [MaxLength(100)]
        public string City { get; set; } = string.Empty;

        [Required(ErrorMessage = "Postanski broj je obavezan.")]
        [MaxLength(20)]
        public string PostalCode { get; set; } = string.Empty;

        [MaxLength(100)]
        public string Country { get; set; } = "Bosna i Hercegovina";
    }
}
