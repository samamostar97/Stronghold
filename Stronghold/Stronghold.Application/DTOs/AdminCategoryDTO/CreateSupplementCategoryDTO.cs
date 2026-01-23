using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.DTOs.AdminCategoryDTO
{
    public class CreateSupplementCategoryDTO
    {
        [Required]
        [MinLength(2,ErrorMessage ="Prekratak naziv")]
        public string Name { get; set; }= string.Empty;

    }
}
