namespace Stronghold.Application.DTOs.Faqs;

public class FaqResponse
{
    public int Id { get; set; }
    public string Question { get; set; } = null!;
    public string Answer { get; set; } = null!;
}
