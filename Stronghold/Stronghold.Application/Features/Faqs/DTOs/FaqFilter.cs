using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Faqs.DTOs;

public class FaqFilter : PaginationRequest
{
    public string? Search { get; set; }
    public string? OrderBy { get; set; }
}
