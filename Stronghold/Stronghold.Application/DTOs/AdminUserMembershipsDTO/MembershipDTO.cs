using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.DTOs.AdminUserMembershipsDTO
{
    public class MembershipDTO
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int MembershipPackageId { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }

    }
}
