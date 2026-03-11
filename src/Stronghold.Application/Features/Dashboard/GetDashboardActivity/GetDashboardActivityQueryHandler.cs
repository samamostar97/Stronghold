using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Enums;

namespace Stronghold.Application.Features.Dashboard.GetDashboardActivity;

public class GetDashboardActivityQueryHandler : IRequestHandler<GetDashboardActivityQuery, List<DashboardActivityResponse>>
{
    private readonly IOrderRepository _orderRepository;
    private readonly IAppointmentRepository _appointmentRepository;
    private readonly IUserRepository _userRepository;
    private readonly IReviewRepository _reviewRepository;

    public GetDashboardActivityQueryHandler(
        IOrderRepository orderRepository,
        IAppointmentRepository appointmentRepository,
        IUserRepository userRepository,
        IReviewRepository reviewRepository)
    {
        _orderRepository = orderRepository;
        _appointmentRepository = appointmentRepository;
        _userRepository = userRepository;
        _reviewRepository = reviewRepository;
    }

    public async Task<List<DashboardActivityResponse>> Handle(GetDashboardActivityQuery request, CancellationToken cancellationToken)
    {
        var activities = new List<DashboardActivityResponse>();

        // Recent orders
        var recentOrders = await _orderRepository.Query()
            .Include(o => o.User)
            .OrderByDescending(o => o.CreatedAt)
            .Take(request.Count)
            .Select(o => new DashboardActivityResponse
            {
                Type = "order",
                Message = $"{o.User.FirstName} {o.User.LastName} je kreirao narudzbu #{o.Id} ({o.TotalAmount:F2} KM)",
                CreatedAt = o.CreatedAt
            })
            .ToListAsync(cancellationToken);

        // Recent appointments
        var recentAppointments = await _appointmentRepository.Query()
            .Include(a => a.User)
            .Include(a => a.Staff)
            .OrderByDescending(a => a.CreatedAt)
            .Take(request.Count)
            .Select(a => new DashboardActivityResponse
            {
                Type = "appointment",
                Message = $"{a.User.FirstName} {a.User.LastName} je zakazao termin sa {a.Staff.FirstName} {a.Staff.LastName}",
                CreatedAt = a.CreatedAt
            })
            .ToListAsync(cancellationToken);

        // Recent registrations
        var recentUsers = await _userRepository.Query()
            .Where(u => u.Role == Role.User)
            .OrderByDescending(u => u.CreatedAt)
            .Take(request.Count)
            .Select(u => new DashboardActivityResponse
            {
                Type = "registration",
                Message = $"{u.FirstName} {u.LastName} se registrovao",
                CreatedAt = u.CreatedAt
            })
            .ToListAsync(cancellationToken);

        // Recent reviews
        var recentReviews = await _reviewRepository.Query()
            .Include(r => r.User)
            .Include(r => r.Product)
            .OrderByDescending(r => r.CreatedAt)
            .Take(request.Count)
            .Select(r => new DashboardActivityResponse
            {
                Type = "review",
                Message = r.ReviewType == ReviewType.Product
                    ? $"{r.User.FirstName} {r.User.LastName} je ostavio recenziju za {r.Product!.Name}"
                    : $"{r.User.FirstName} {r.User.LastName} je ostavio recenziju za termin",
                CreatedAt = r.CreatedAt
            })
            .ToListAsync(cancellationToken);

        activities.AddRange(recentOrders);
        activities.AddRange(recentAppointments);
        activities.AddRange(recentUsers);
        activities.AddRange(recentReviews);

        return activities
            .OrderByDescending(a => a.CreatedAt)
            .Take(request.Count)
            .ToList();
    }
}
