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
        [StringLength(25,MinimumLength =2, ErrorMessage = "Ime moze da ima 2-25 karaktera")]
        public string? FirstName { get; set; }
        [StringLength(25, MinimumLength = 2, ErrorMessage = "Prezime moze da ima 2-25 karaktera")]
        public string? LastName { get; set; }
        [EmailAddress(ErrorMessage ="Neispravan format email adrese")]
        [StringLength(50,ErrorMessage = "Email predug")]
        public string? Email { get; set; }
        [RegularExpression(
      @"^(\+387|387|0)?\s?6\d([-\s]?\d){6,7}$",
      ErrorMessage = "Broj telefona mora biti u formatu 061 123 456 ")]
        public string? PhoneNumber { get; set; } 
    }
}
