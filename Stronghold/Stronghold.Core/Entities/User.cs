using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Stronghold.Core.Enums;

namespace Stronghold.Core.Entities
{
    public class User
    {
        public int Id { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }
        public string PasswordHash { get; set; }
        public Role Role { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }

        public ICollection<Membership> Memberships { get; set; }
        public ICollection<Order> Orders { get; set; }
        public ICollection<Review> Reviews { get; set; }
        public ICollection<Appointment> AppointmentsAsMember { get; set; }
        public ICollection<Appointment> AppointmentsAsProfessional { get; set; }
        public ICollection<Seminar> Seminars { get; set; }
        public ICollection<Progress> ProgressRecords { get; set; }
        public ICollection<RefreshToken> RefreshTokens { get; set; }
    }
}
