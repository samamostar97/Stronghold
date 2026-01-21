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
        [StringLength(15, ErrorMessage = "Unos usernamea obavezan")]
        public string Username { get; set; } = string.Empty;
        [Required]
        [EmailAddress(ErrorMessage ="Neispravan format email-a")]
        public string Email { get; set; } = string.Empty;
        [Required]
        public string PhoneNumber { get; set; } = string.Empty;
        [Required]
        public Gender Gender { get; set; }
        public Role Role { get; set; }
        [Required]
        public string Password { get; set; } = string.Empty;
    }
}
