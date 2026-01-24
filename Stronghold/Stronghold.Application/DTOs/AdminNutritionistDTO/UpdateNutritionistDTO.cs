using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.DTOs.AdminNutritionistDTO
{
    public class UpdateNutritionistDTO
    {
        [StringLength(30, MinimumLength = 2, ErrorMessage = "Ime nutricioniste moze da sadrzi 2-30 karaktera")]
        public string? FirstName { get; set; }
        [StringLength(30, MinimumLength = 2, ErrorMessage = "Prezime nutricioniste moze da sadrzi 2-30 karaktera")]
        public string? LastName { get; set; }
        [EmailAddress(ErrorMessage = "Neispravan format email adrese")]
        [StringLength(50, MinimumLength = 2, ErrorMessage = "Unos email adrese obavezan")]

        public string? Email { get; set; }
        [RegularExpression(
        @"^(\+387|387|0)?\s?6\d([-\s]?\d){6,7}$",
        ErrorMessage = "Broj telefona mora biti u formatu 061 123 456 ili +387 61 123 456")]
        [StringLength(15, MinimumLength = 11, ErrorMessage = "Unesite ispravan broj telefona")]

        public string? PhoneNumber { get; set; }
    }
}
