using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.GymVisits.GetGymVisits;

[AuthorizeRole("Admin")]
public class GetGymVisitsQuery : BaseQueryFilter, IRequest<PagedResult<GymVisitResponse>>
{
    public int? UserId { get; set; }
    public DateTime? DateFrom { get; set; }
    public DateTime? DateTo { get; set; }
}
