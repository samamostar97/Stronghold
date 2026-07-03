using Stronghold.Application.Common;

namespace Stronghold.Application.DTOs.Payments;

public class PaymentSearch : BaseSearchObject
{
    public int? UserId { get; set; }
    /// <summary>Pretraga po imenu, prezimenu ili korisnickom imenu clana.</summary>
    public string? Text { get; set; }
    public DateTime? From { get; set; }
    public DateTime? To { get; set; }
}
