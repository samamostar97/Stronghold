using Stronghold.Application.Common;

namespace Stronghold.Application.DTOs.Faqs;

public class FaqSearch : BaseSearchObject
{
    // Pretraga po pitanju ili odgovoru.
    public string? Text { get; set; }
}
