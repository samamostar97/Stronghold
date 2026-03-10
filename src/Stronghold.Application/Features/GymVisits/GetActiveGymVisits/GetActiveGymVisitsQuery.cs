using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.GymVisits.GetActiveGymVisits;

[AuthorizeRole("Admin")]
public class GetActiveGymVisitsQuery : IRequest<List<GymVisitResponse>>
{
}
