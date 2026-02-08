namespace Stronghold.Application.DTOs.Response
{
    public class MembershipResponse
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int MembershipPackageId { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
    }
}
