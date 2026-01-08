using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Core.Entities
{
    public class SeminarEnrollment
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int SeminarId { get; set; }
        public DateTime EnrolledAt { get; set; }
        public bool IsAttended { get; set; }
        public bool IsCancelled { get; set; }

        public User User { get; set; }
        public Seminar Seminar { get; set; }
    }
}
