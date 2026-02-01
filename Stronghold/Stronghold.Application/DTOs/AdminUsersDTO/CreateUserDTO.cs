using Stronghold.Core.Enums;
using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.AdminUsersDTO
{
    public class CreateUserDTO
    {
        [Required(ErrorMessage = "Ime je obavezno.")]
        [StringLength(100, MinimumLength = 2, ErrorMessage = "Ime mora imati između 2 i 100 karaktera.")]
        public string FirstName { get; set; } = string.Empty;

        [Required(ErrorMessage = "Prezime je obavezno.")]
        [StringLength(100, MinimumLength = 2, ErrorMessage = "Prezime mora imati između 2 i 100 karaktera.")]
        public string LastName { get; set; } = string.Empty;

        [Required(ErrorMessage = "Korisničko ime je obavezno.")]
        [StringLength(50, MinimumLength = 3, ErrorMessage = "Korisničko ime mora imati između 3 i 50 karaktera.")]
        public string Username { get; set; } = string.Empty;

        [Required(ErrorMessage = "Email je obavezan.")]
        [EmailAddress(ErrorMessage = "Neispravan format email adrese.")]
        [StringLength(255, MinimumLength = 5, ErrorMessage = "Email mora imati između 5 i 255 karaktera.")]
        public string Email { get; set; } = string.Empty;

        [Required(ErrorMessage = "Broj telefona je obavezan.")]
        [RegularExpression(
            @"^(\+387|387|0)?\s?6\d([-\s]?\d){6,7}$",
            ErrorMessage = "Broj telefona mora biti u formatu 061 123 456 ili +387 61 123 456.")]
        [StringLength(20, MinimumLength = 9, ErrorMessage = "Broj telefona mora imati između 9 i 20 karaktera.")]
        public string PhoneNumber { get; set; } = string.Empty;

        [Required(ErrorMessage = "Spol je obavezan.")]
        [EnumDataType(typeof(Gender), ErrorMessage = "Neispravan unos spola.")]
        public Gender Gender { get; set; }

        [Required(ErrorMessage = "Lozinka je obavezna.")]
        [StringLength(100, MinimumLength = 6, ErrorMessage = "Lozinka mora imati između 6 i 100 karaktera.")]
        public string Password { get; set; } = string.Empty;
    }
}
