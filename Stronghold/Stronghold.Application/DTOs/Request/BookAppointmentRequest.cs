using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Request
{
    public class BookAppointmentRequest
    {
        [Required(ErrorMessage = "Datum termina je obavezan.")]
        public DateTime Date { get; set; }
    }
}
