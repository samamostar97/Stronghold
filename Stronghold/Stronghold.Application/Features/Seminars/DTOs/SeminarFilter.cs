using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Seminars.DTOs;

public class SeminarFilter : PaginationRequest
{
    public string? Search { get; set; }

public string? OrderBy { get; set; }

public bool? IsCancelled { get; set; }

public string? Status { get; set; }
}
