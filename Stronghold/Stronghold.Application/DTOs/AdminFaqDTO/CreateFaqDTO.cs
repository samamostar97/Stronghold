using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.DTOs.AdminFaqDTO
{
    public class CreateFaqDTO
    {
        [Required(ErrorMessage ="Unos pitanja obavezan")]
        [StringLength(255,MinimumLength =2,ErrorMessage ="Pitanje moze da sadrzi 2-255 karaktera")]
        public string Question { get; set; } = string.Empty;
        [Required(ErrorMessage = "Unos odgovora obavezan")]
        [StringLength(255, MinimumLength = 2, ErrorMessage = "Odgovor moze da sadrzi 2-255 karaktera")]
        public string Answer { get; set; } = string.Empty;
    }
}
