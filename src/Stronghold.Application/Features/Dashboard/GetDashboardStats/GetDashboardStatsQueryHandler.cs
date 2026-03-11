using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Enums;

namespace Stronghold.Application.Features.Dashboard.GetDashboardStats;

public class GetDashboardStatsQueryHandler : IRequestHandler<GetDashboardStatsQuery, DashboardStatsResponse>
{
    private readonly IGymVisitRepository _gymVisitRepository;
    private readonly IUserMembershipRepository _membershipRepository;
    private readonly IOrderRepository _orderRepository;
    private readonly IAppointmentRepository _appointmentRepository;

    public GetDashboardStatsQueryHandler(
        IGymVisitRepository gymVisitRepository,
        IUserMembershipRepository membershipRepository,
        IOrderRepository orderRepository,
        IAppointmentRepository appointmentRepository)
    {
        _gymVisitRepository = gymVisitRepository;
        _membershipRepository = membershipRepository;
        _orderRepository = orderRepository;
        _appointmentRepository = appointmentRepository;
    }

    public async Task<DashboardStatsResponse> Handle(GetDashboardStatsQuery request, CancellationToken cancellationToken)
    {
        var activeVisits = await _gymVisitRepository.Query()
            .CountAsync(v => v.CheckOutAt == null, cancellationToken);

        var activeMemberships = await _membershipRepository.Query()
            .CountAsync(m => m.IsActive && m.EndDate > DateTime.UtcNow, cancellationToken);

        var pendingOrders = await _orderRepository.Query()
            .CountAsync(o => o.Status == OrderStatus.Pending, cancellationToken);

        var pendingAppointments = await _appointmentRepository.Query()
            .CountAsync(a => a.Status == AppointmentStatus.Pending, cancellationToken);

        return new DashboardStatsResponse
        {
            ActiveGymVisits = activeVisits,
            ActiveMemberships = activeMemberships,
            PendingOrders = pendingOrders,
            PendingAppointments = pendingAppointments
        };
    }
}
