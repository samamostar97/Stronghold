using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Request
{
    public class CancelOrderRequest
    {
        [StringLength(500, ErrorMessage = "Razlog moze imati najvise 500 karaktera.")]
        public string? Reason { get; set; }
    }
}
