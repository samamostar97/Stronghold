using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Reviews.DTOs;

public class ReviewFilter : PaginationRequest
{
    public string? Search { get; set; }
    public string? OrderBy { get; set; }
}
