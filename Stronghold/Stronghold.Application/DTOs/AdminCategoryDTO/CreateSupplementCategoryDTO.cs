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
        [Required(ErrorMessage = "Naziv je obavezan.")]
        [StringLength(100, MinimumLength = 2, ErrorMessage = "Naziv mora imati između 2 i 100 karaktera.")]
        public string Name { get; set; } = string.Empty;
    }
}
