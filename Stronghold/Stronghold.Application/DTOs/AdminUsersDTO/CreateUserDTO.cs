using Stronghold.Core.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.DTOs.AdminUsersDTO
{
    public class CreateUserDTO
    {
        [Required]
        [StringLength(25,ErrorMessage ="Unos imena obavezan")]
        public string FirstName { get; set; } = string.Empty;
        [Required]
        [StringLength(25, ErrorMessage = "Unos prezimena obavezan")]
        public string LastName { get; set; } = string.Empty;
        [Required]
        [StringLength(15, MinimumLength = 3, ErrorMessage = "Username mora biti između 3 i 15 karaktera")]
        public string Username { get; set; } = string.Empty;
        [Required]
        [EmailAddress(ErrorMessage ="Neispravan format email-a")]
        public string Email { get; set; } = string.Empty;
        [Required]
        [RegularExpression(
            @"^(\+387|387|0)?\s?6\d([-\s]?\d){6,7}$",
            ErrorMessage = "Broj telefona mora biti u formatu 061 123 456 "
        )]
        public string PhoneNumber { get; set; } = string.Empty;
        [Required]
        [EnumDataType(typeof(Gender), ErrorMessage = "Neispravan unos spola")]
        public Gender Gender { get; set; }
        [Required]
        [StringLength(25,MinimumLength = 6,ErrorMessage = "Password mora biti izmedju 6 i 25 karaktera dug")]
        public string Password { get; set; } = string.Empty;
    }
}
