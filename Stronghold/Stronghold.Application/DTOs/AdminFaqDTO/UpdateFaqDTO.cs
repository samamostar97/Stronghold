using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.DTOs.AdminFaqDTO
{
    public class UpdateFaqDTO
    {
        [StringLength(255, MinimumLength = 2, ErrorMessage = "Pitanje predugo")]
        public string? Question { get; set; }
        [StringLength(255, MinimumLength = 2, ErrorMessage = "Odgovor predug")]
        public string? Answer { get; set; }
    }
}
