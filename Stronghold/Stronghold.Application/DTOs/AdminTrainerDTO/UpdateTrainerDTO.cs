using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.DTOs.AdminTrainerDTO
{
    public class UpdateTrainerDTO
    {
        public string? FirstName { get; set; } 
        public string? LastName { get; set; } 
        public string? Email { get; set; } 
        public string? PhoneNumber { get; set; } 
    }
}
