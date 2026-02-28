using Stronghold.Application.Common;
using Stronghold.Core.Enums;

namespace Stronghold.Application.Features.Orders.DTOs;

public class OrderFilter : PaginationRequest
{
    public string? Search { get; set; }

public int? UserId { get; set; }

public OrderStatus? Status { get; set; }

public DateTime? DateFrom { get; set; }

public DateTime? DateTo { get; set; }

public string? OrderBy { get; set; }

public bool Descending { get; set; } = true;
}
