using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Memberships.DTOs;

public class ActiveMemberFilter : PaginationRequest
{
    public string? Name { get; set; }
}
