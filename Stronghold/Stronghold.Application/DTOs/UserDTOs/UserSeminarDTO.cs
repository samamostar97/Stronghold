using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.DTOs.UserDTOs
{
    public class UserSeminarDTO
    {
        public int Id { get; set; }
        public string Topic { get; set; } = string.Empty;
        public string SpeakerName { get; set; } = string.Empty;
        public DateTime EventDate { get; set; }
        public bool IsAttending { get; set; }
    }
}
