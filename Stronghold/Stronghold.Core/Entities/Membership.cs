namespace Stronghold.Core.Entities;

    public class Membership : BaseEntity
    {
        public int UserId { get; set; }
        public int MembershipPackageId { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }

        // Navigation properties
        public User User { get; set; } = null!;
        public MembershipPackage MembershipPackage { get; set; } = null!;
    }

