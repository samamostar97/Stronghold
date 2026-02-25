using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Supplements.DTOs;

public class SupplementFilter : PaginationRequest
{
    public string? Search { get; set; }

public string? OrderBy { get; set; }

public int? SupplementCategoryId { get; set; }
}
