namespace Stronghold.Application.DTOs.Response
{
    public class SeminarResponse
    {
        public int Id { get; set; }
        public string Topic { get; set; } = string.Empty;
        public string SpeakerName { get; set; } = string.Empty;
        public DateTime EventDate { get; set; }
        public int MaxCapacity { get; set; }
        public int CurrentAttendees { get; set; }
        public bool IsCancelled { get; set; }
        public string Status { get; set; } = "active";
    }
}
