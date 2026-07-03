using Stronghold.Application.Common;

namespace Stronghold.Application.DTOs.Faqs;

public class FaqSearch : BaseSearchObject
{
    /// <summary>Pretraga po pitanju ili odgovoru.</summary>
    public string? Text { get; set; }
}
