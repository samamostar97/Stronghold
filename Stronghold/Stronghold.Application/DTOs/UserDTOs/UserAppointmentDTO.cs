using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.DTOs.UserDTOs
{
    public class UserAppointmentDTO
    {
        public int Id { get; set; }
        public string? TrainerName { get; set; }
        public string? NutritionistName { get; set; }
        public DateTime AppointmentDate { get; set; }
    }
}
