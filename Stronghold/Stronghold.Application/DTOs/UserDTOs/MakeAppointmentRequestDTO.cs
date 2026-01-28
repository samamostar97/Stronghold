using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.UserDTOs
{
    public class MakeAppointmentRequestDTO
    {
        [Required]
        public int StaffId { get; set; }

        [Required]
        public DateTime AppointmentDate { get; set; }
    }
}
