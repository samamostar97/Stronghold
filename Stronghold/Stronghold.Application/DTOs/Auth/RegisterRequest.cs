using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Auth;

public class RegisterRequest
{
    [Required]
    [StringLength(50)]
    public string FirstName { get; set; } = string.Empty;

    [Required]
    [StringLength(50)]
    public string LastName { get; set; } = string.Empty;

    [Required]
    [StringLength(30, MinimumLength = 3,ErrorMessage ="Username mora biti iznad 3 karaktera")]
    public string Username { get; set; } = string.Empty;

    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;

    [Required]
    [RegularExpression(
        @"^(\+387|387|0)?\s?6\d([-\s]?\d){6,7}$",
        ErrorMessage = "Broj telefona mora biti u formatu 061 123 456 ili +387 61 123 456")]
    public string PhoneNumber { get; set; } = string.Empty;

    [Required]
    [MinLength(6,ErrorMessage ="Password mora sadrzavati vi�e od 6 karaktera")]
    public string Password { get; set; } = string.Empty;
}
