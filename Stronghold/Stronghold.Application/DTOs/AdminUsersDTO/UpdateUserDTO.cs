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
        [StringLength(25, MinimumLength = 2)]
        public string? FirstName { get; set; }
        [StringLength(25, MinimumLength = 2)]
        public string? LastName { get; set; }
        [StringLength(15, MinimumLength = 2)]
        public string? Username { get; set; }
        [EmailAddress(ErrorMessage ="Neispravan format email adrese")]
        [StringLength(50)]
        public string? Email { get; set; }
        [RegularExpression(
         @"^(\+387|387|0)?\s?6\d([-\s]?\d){6,7}$",
         ErrorMessage = "Broj telefona mora biti u formatu 061 123 456 ")]
        public string? PhoneNumber { get; set; }
        [StringLength(25, MinimumLength = 6, ErrorMessage = "Password mora imati 6–25 karaktera")]
        public string? Password { get; set; } 
    }
}
