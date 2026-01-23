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
        [MinLength(2,ErrorMessage ="Prekratak naziv teme")]
        public string Topic { get; set; } = string.Empty;
        [Required(ErrorMessage = "Unos naziva govornika obavezan")]
        [MinLength(2, ErrorMessage = "Prekratak naziv govornika")]
        public string SpeakerName { get; set; } = string.Empty;
        [Required]
        public DateTime EventDate { get; set; }
    }
}
