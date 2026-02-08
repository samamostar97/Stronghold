using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Request
{
    public class UpdateSupplierRequest
    {
        [StringLength(50, MinimumLength = 2, ErrorMessage = "Naziv dobavljača mora imati između 2 i 50 karaktera.")]
        public string? Name { get; set; }

        [StringLength(100, MinimumLength = 5, ErrorMessage = "Web stranica mora imati između 5 i 100 karaktera.")]
        [RegularExpression(
            @"^(https?://)?(www\.)?([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(/.*)?$",
            ErrorMessage = "Unesite ispravnu web adresu (npr. www.example.com).")]
        public string? Website { get; set; }
    }
}
