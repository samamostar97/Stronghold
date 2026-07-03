using Stronghold.Application.Common;
using Stronghold.Core.Enums;

namespace Stronghold.Application.DTOs.Orders;

public class OrderSearch : BaseSearchObject
{
    public OrderStatus? Status { get; set; }
    /// <summary>Pretraga po imenu, prezimenu ili korisnickom imenu kupca.</summary>
    public string? Text { get; set; }
    public DateTime? From { get; set; }
    public DateTime? To { get; set; }
}
