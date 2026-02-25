using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Visits.DTOs;

public class VisitFilter : PaginationRequest
{
    public string? Search { get; set; }

public string? OrderBy { get; set; }
}
