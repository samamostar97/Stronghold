using Stronghold.Application.Common;

namespace Stronghold.Application.DTOs.Payments;

public class PaymentSearch : BaseSearchObject
{
    public int? UserId { get; set; }
    public DateTime? From { get; set; }
    public DateTime? To { get; set; }
}
