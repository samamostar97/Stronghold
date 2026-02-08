namespace Stronghold.Application.DTOs.Response
{
    public class ActiveMemberResponse
    {
        public int UserId { get; set; }
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string Username { get; set; } = string.Empty;
        public string? ProfileImageUrl { get; set; }
        public string PackageName { get; set; } = string.Empty;
        public DateTime MembershipEndDate { get; set; }
    }
}
