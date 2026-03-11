using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Dashboard.GetDashboardActivity;

[AuthorizeRole("Admin")]
public class GetDashboardActivityQuery : IRequest<List<DashboardActivityResponse>>
{
    public int Count { get; set; } = 15;
}
