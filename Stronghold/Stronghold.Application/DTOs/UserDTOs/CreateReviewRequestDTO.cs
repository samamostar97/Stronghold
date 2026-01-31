namespace Stronghold.Application.DTOs.UserDTOs;

public class CreateReviewRequestDTO
{
    public int SupplementId { get; set; }
    public int Rating { get; set; }
    public string? Comment { get; set; }
}
