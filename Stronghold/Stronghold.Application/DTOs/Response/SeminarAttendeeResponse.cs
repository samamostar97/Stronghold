namespace Stronghold.Application.DTOs.Response
{
    public class SeminarAttendeeResponse
    {
        public int UserId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public DateTime RegisteredAt { get; set; }
    }
}
