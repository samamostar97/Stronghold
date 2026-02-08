namespace Stronghold.Application.DTOs.Response
{
    public class LeaderboardEntryResponse
    {
        public int Rank { get; set; }
        public int UserId { get; set; }
        public string FullName { get; set; } = string.Empty;
        public string? ProfileImageUrl { get; set; }
        public int Level { get; set; }
        public int CurrentXP { get; set; }
    }
}
