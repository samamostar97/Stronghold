using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.DTOs.AdminTrainerDTO
{
    public class UpdateTrainerDTO
    {
        [StringLength(50, MinimumLength = 2, ErrorMessage = "Ime trenera moze da sadrzi 2-50 karaktera")]
        public string? FirstName { get; set; }
        [StringLength(50, MinimumLength = 2, ErrorMessage = "Prezime trenera moze da sadrzi 2-50 karaktera")]
        public string? LastName { get; set; }
        [EmailAddress(ErrorMessage = "Neispravan format email adrese")]
        public string? Email { get; set; }
        [RegularExpression(
         @"^(\+387|387|0)?\s?6\d([-\s]?\d){6,7}$",
         ErrorMessage = "Broj telefona mora biti u formatu 061 123 456 ili +387 61 123 456")]
        public string? PhoneNumber { get; set; } 
    }
}
