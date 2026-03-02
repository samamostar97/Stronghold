using Stronghold.Application.Common;

namespace Stronghold.Application.Features.AdminActivities.DTOs;

public class AdminActivityFilter : PaginationRequest
{
    public string? Search { get; set; }
    public string? OrderBy { get; set; }
    public string? ActionType { get; set; }
    public string? EntityType { get; set; }
}
