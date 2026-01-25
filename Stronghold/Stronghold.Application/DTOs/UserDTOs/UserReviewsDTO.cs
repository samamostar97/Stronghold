using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.DTOs.UserDTOs
{
    public class UserReviewsDTO
    {
        public int Id { get; set; }
        public string SupplementName { get; set; } = string.Empty;
        public int Rating { get; set; }
        public string? Comment { get; set; }= string.Empty;
    }
}
