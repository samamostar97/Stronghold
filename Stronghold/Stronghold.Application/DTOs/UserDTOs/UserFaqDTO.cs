namespace Stronghold.Application.DTOs.UserDTOs
{
    public class UserFaqDTO
    {
        public int Id { get; set; }
        public string Question { get; set; } = string.Empty;
        public string Answer { get; set; } = string.Empty;
    }
}
