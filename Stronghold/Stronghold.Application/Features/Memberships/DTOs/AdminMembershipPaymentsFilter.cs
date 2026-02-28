using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Memberships.DTOs;

public class AdminMembershipPaymentsFilter : PaginationRequest
{
    public string? Search { get; set; }
    public string? OrderBy { get; set; }
}
