using Stronghold.Application.Common;

namespace Stronghold.Application.DTOs.Reviews;

public class ReviewSearch : BaseSearchObject
{
    /// <summary>Pretraga po korisniku ili suplementu.</summary>
    public string? Text { get; set; }
    public int? SupplementId { get; set; }
    public int? Rating { get; set; }
}
