using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Auth;

public class RefreshRequest
{
    [Required(ErrorMessage = "Refresh token je obavezan.")]
    public string RefreshToken { get; set; } = null!;
}
