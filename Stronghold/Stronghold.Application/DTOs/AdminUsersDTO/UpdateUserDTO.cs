using Stronghold.Core.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.DTOs.AdminUsersDTO
{
    public class UpdateUserDTO
    {
        [StringLength(30, MinimumLength = 2, ErrorMessage = "Ime moze da sadrzi 2-30 karaktera")]
        public string? FirstName { get; set; }
        [StringLength(30, MinimumLength = 2, ErrorMessage = "Prezime moze da sadrzi 2-30 karaktera")]
        public string? LastName { get; set; }
        [StringLength(15, MinimumLength = 3, ErrorMessage = "Username moze da sadrzi 3-15 karaktera")]
        public string? Username { get; set; }
        [EmailAddress(ErrorMessage ="Neispravan format email adrese")]
        [StringLength(50, MinimumLength = 5, ErrorMessage = "Unos Email adrese obavezan")]

        public string? Email { get; set; }
        [RegularExpression(
         @"^(\+387|387|0)?\s?6\d([-\s]?\d){6,7}$",
         ErrorMessage = "Broj telefona mora biti u formatu 061 123 456 ili +387 61 123 456")]
        [StringLength(15,MinimumLength = 11,ErrorMessage ="Unos broja telefona obavezan")]
        public string? PhoneNumber { get; set; }
        [StringLength(25, MinimumLength = 6, ErrorMessage = "Password mora imati 6–25 karaktera")]
        public string? Password { get; set; } 
    }
}
