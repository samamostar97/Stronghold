using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.GymVisits.GetEligibleForCheckIn;

[AuthorizeRole("Admin")]
public class GetEligibleForCheckInQuery : IRequest<PagedResult<EligibleMemberResponse>>
{
    public int PageNumber { get; set; } = 1;
    public int PageSize { get; set; } = 100;
    public string? Search { get; set; }
}
