using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.DTOs.AdminVisitsDTO
{
    public class CurrentVisitorDTO
    {
        public int UserId { get; set; }
        public int GymVisitId { get; set; }
        public string Username { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public DateTime CheckInTime { get; set; }
        public string Duration { get; set; } = string.Empty;

    }
}
