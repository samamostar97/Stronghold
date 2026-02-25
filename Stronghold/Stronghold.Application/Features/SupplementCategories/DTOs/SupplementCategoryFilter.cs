using Stronghold.Application.Common;

namespace Stronghold.Application.Features.SupplementCategories.DTOs;

public class SupplementCategoryFilter : PaginationRequest
{
    public string? Search { get; set; }

public string? OrderBy { get; set; }
}
