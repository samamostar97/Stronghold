using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.DTOs.AdminSeminarDTO
{
    public class CreateSeminarDTO
    {
        [Required(ErrorMessage ="Unos naziva teme obavezan")]
        [StringLength(50, MinimumLength = 2, ErrorMessage = "Naziv teme moze da sadrzi 2-50 karaktera")]
        public string Topic { get; set; } = string.Empty;
        [Required(ErrorMessage = "Unos naziva govornika obavezan")]
        [StringLength(30, MinimumLength = 2, ErrorMessage = "Naziv govornika moze da sadrzi 2-30 karaktera")]
        public string SpeakerName { get; set; } = string.Empty;
        [Required]
        public DateTime EventDate { get; set; }
    }
}
