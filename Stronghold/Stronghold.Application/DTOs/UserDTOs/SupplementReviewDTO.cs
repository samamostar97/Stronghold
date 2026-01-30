namespace Stronghold.Application.DTOs.UserDTOs
{
    public class SupplementReviewDTO
    {
        public int Id { get; set; }
        public string UserName { get; set; } = string.Empty;
        public int Rating { get; set; }
        public string? Comment { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
