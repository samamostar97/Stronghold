using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.UserDTOs
{
    public class MakeAppointmentRequestDTO
    {
        [Range(1, int.MaxValue, ErrorMessage = "Osoblje je obavezno.")]
        public int StaffId { get; set; }

        [Required(ErrorMessage = "Datum termina je obavezan.")]
        public DateTime AppointmentDate { get; set; }
    }
}
