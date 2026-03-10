using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.GymVisits.CheckOut;

[AuthorizeRole("Admin")]
public class CheckOutCommand : IRequest<GymVisitResponse>
{
    public int Id { get; set; }
}
