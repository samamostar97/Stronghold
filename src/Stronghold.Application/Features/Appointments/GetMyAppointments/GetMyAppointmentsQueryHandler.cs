using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;

namespace Stronghold.Application.Features.Appointments.GetMyAppointments;

public class GetMyAppointmentsQueryHandler : IRequestHandler<GetMyAppointmentsQuery, PagedResult<AppointmentResponse>>
{
    private readonly IAppointmentRepository _appointmentRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetMyAppointmentsQueryHandler(IAppointmentRepository appointmentRepository, ICurrentUserService currentUserService)
    {
        _appointmentRepository = appointmentRepository;
        _currentUserService = currentUserService;
    }

    public async Task<PagedResult<AppointmentResponse>> Handle(GetMyAppointmentsQuery request, CancellationToken cancellationToken)
    {
        IQueryable<Appointment> query = _appointmentRepository.Query()
            .Include(a => a.User)
            .Include(a => a.Staff)
            .Where(a => a.UserId == _currentUserService.UserId)
            .OrderByDescending(a => a.ScheduledAt);

        var totalCount = await query.CountAsync(cancellationToken);

        var appointments = await query
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .ToListAsync(cancellationToken);

        return new PagedResult<AppointmentResponse>
        {
            Items = appointments.Select(AppointmentMappings.ToResponse).ToList(),
            TotalCount = totalCount,
            TotalPages = (int)Math.Ceiling(totalCount / (double)request.PageSize),
            CurrentPage = request.PageNumber,
            PageSize = request.PageSize
        };
    }
}
