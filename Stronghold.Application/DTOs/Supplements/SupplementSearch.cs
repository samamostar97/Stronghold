using Stronghold.Application.Common;

namespace Stronghold.Application.DTOs.Supplements;

public class SupplementSearch : BaseSearchObject
{
    public string? Text { get; set; }
    public int? CategoryId { get; set; }
    public int? SupplierId { get; set; }
}
