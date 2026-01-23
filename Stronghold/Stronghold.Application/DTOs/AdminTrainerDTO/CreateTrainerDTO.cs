using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.DTOs.AdminTrainerDTO
{
    public class CreateTrainerDTO
    {
        [Required]
        [MinLength(2, ErrorMessage = "Prekratak naziv")]
        public string FirstName { get; set; } = string.Empty;
        [Required]
        [MinLength(2, ErrorMessage = "Prekratak naziv")]
        public string LastName { get; set; } = string.Empty;
        [Required]
        [EmailAddress(ErrorMessage = "Neispravan format email adrese")]
        public string Email { get; set; } = string.Empty;
        [Required]
        public string PhoneNumber { get; set; } = string.Empty;
    }
}
