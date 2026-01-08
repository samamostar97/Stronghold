using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Core.Entities
{
    public class Seminar
    {
        public int Id { get; set; }
        public string Theme { get; set; }
        public int LecturerId { get; set; }
        public DateTime ScheduledDate { get; set; }
        public int DurationMinutes { get; set; }
        public string Description { get; set; }
        public bool IsCancelled { get; set; }
        public DateTime CreatedAt { get; set; }

        public User Lecturer { get; set; }
    }
}
