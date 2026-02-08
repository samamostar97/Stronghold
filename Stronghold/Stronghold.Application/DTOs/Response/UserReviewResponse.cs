namespace Stronghold.Application.DTOs.Response
{
    public class UserReviewResponse
    {
        public int Id { get; set; }
        public string SupplementName { get; set; } = string.Empty;
        public int Rating { get; set; }
        public string? Comment { get; set; }
    }
}
