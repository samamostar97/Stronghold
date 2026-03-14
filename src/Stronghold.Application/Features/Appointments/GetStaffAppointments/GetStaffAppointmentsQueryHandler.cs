using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;

namespace Stronghold.Application.Features.Appointments.GetStaffAppointments;

public class GetStaffAppointmentsQueryHandler : IRequestHandler<GetStaffAppointmentsQuery, PagedResult<AppointmentResponse>>
{
    private readonly IAppointmentRepository _appointmentRepository;

    public GetStaffAppointmentsQueryHandler(IAppointmentRepository appointmentRepository)
    {
        _appointmentRepository = appointmentRepository;
    }

    public async Task<PagedResult<AppointmentResponse>> Handle(GetStaffAppointmentsQuery request, CancellationToken cancellationToken)
    {
        IQueryable<Appointment> query = _appointmentRepository.QueryAll()
            .Include(a => a.User)
            .Include(a => a.Staff)
            .Where(a => a.StaffId == request.StaffId)
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
