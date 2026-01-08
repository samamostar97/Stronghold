using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Core.Entities
{
    public class Membership
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int MembershipPackageId { get; set; }
        public DateTime EndDate { get; set; }
        public bool IsPaid { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }

        public User User { get; set; }
        public MembershipPackage MembershipPackage { get; set; }
    }
}
