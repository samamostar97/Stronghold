using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Memberships.DTOs;

public class MembershipPaymentFilter : PaginationRequest
{
    public string? OrderBy { get; set; }
}
