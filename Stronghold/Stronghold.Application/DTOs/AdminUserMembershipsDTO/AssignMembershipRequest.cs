using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.DTOs.AdminUserMembershipsDTO
{
    public class AssignMembershipRequest
    {
        [Required]
        public int UserId { get; set; }
        [Required]
        public int MembershipPackageId { get; set; }
        [Required]
        [Range(5,10000)]
        public decimal AmountPaid { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public DateTime PaymentDate { get; set; }
    }
}
