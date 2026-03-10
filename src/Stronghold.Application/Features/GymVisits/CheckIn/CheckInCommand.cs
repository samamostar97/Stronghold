using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.GymVisits.CheckIn;

[AuthorizeRole("Admin")]
public class CheckInCommand : IRequest<GymVisitResponse>
{
    public int UserId { get; set; }
}
