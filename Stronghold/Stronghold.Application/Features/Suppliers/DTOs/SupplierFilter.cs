using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Suppliers.DTOs;

public class SupplierFilter : PaginationRequest
{
    public string? Search { get; set; }

public string? OrderBy { get; set; }
}
