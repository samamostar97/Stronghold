using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.DTOs.AdminNutritionistDTO
{
    public class UpdateNutritionistDTO
    {
        [MinLength(2)]
        public string? FirstName { get; set; }
        [MinLength(2)]
        public string? LastName { get; set; }
        [EmailAddress(ErrorMessage = "Neispravan format email adrese")]
        public string? Email { get; set; }
        [RegularExpression(
        @"^(\+387|387|0)?\s?6\d([-\s]?\d){6,7}$",
        ErrorMessage = "Broj telefona mora biti u formatu 061 123 456 ")]
        public string? PhoneNumber { get; set; }
    }
}
