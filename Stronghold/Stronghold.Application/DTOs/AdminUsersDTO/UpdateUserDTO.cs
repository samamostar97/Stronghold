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
        public string? FirstName { get; set; } 
        public string? LastName { get; set; } 
        public string? Username { get; set; }
        [EmailAddress(ErrorMessage ="Neispravan format email adrese")]
        public string? Email { get; set; } 
        public string? PhoneNumber { get; set; }
        [MinLength(6,ErrorMessage = "Password mora sadrzavati vise od 6 karaktera")]
        public string? Password { get; set; } 
    }
}
