using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.DTOs.AdminReviewDTO
{
    public class ReviewDTO
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string UserName { get; set; }=string.Empty;
        public int SupplementId { get; set; }
        public string SupplementName { get; set; }=string.Empty;
        public int Rating { get; set; }
        public string? Comment { get; set; }
    }
}
