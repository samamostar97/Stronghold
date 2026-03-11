using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Dashboard.GetDashboardStats;

[AuthorizeRole("Admin")]
public class GetDashboardStatsQuery : IRequest<DashboardStatsResponse>
{
}
