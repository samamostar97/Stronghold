using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Stronghold.Core.Enums;

namespace Stronghold.Core.Entities
{
    public class Appointment
    {
        public int Id { get; set; }
        public int MemberId { get; set; }
        public int ProfessionalId { get; set; }
        public AppointmentType AppointmentType { get; set; }
        public DateTime AppointmentDate { get; set; }
        public int DurationMinutes { get; set; }
        public string? Notes { get; set; }
        public bool IsCompleted { get; set; }
        public bool IsCancelled { get; set; }
        public DateTime CreatedAt { get; set; }

        public User Member { get; set; }
        public User Professional { get; set; }
    }
}
