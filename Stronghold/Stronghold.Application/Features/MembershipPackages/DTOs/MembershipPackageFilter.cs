using Stronghold.Application.Common;

namespace Stronghold.Application.Features.MembershipPackages.DTOs;

public class MembershipPackageFilter : PaginationRequest
{
    public string? Search { get; set; }
    public string? OrderBy { get; set; }
}
