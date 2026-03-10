using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;
using Stronghold.Domain.Enums;

namespace Stronghold.Application.Features.Appointments.GetAppointments;

public class GetAppointmentsQueryHandler : IRequestHandler<GetAppointmentsQuery, PagedResult<AppointmentResponse>>
{
    private readonly IAppointmentRepository _appointmentRepository;

    public GetAppointmentsQueryHandler(IAppointmentRepository appointmentRepository)
    {
        _appointmentRepository = appointmentRepository;
    }

    public async Task<PagedResult<AppointmentResponse>> Handle(GetAppointmentsQuery request, CancellationToken cancellationToken)
    {
        IQueryable<Appointment> query = _appointmentRepository.Query()
            .Include(a => a.User)
            .Include(a => a.Staff);

        if (!string.IsNullOrWhiteSpace(request.Status) && Enum.TryParse<AppointmentStatus>(request.Status, true, out var status))
            query = query.Where(a => a.Status == status);

        if (request.StaffId.HasValue)
            query = query.Where(a => a.StaffId == request.StaffId.Value);

        if (request.UserId.HasValue)
            query = query.Where(a => a.UserId == request.UserId.Value);

        if (request.FromDate.HasValue)
            query = query.Where(a => a.ScheduledAt >= request.FromDate.Value);

        if (request.ToDate.HasValue)
            query = query.Where(a => a.ScheduledAt <= request.ToDate.Value);

        if (!string.IsNullOrWhiteSpace(request.Search))
        {
            var search = request.Search.ToLower();
            query = query.Where(a =>
                a.User.FirstName.ToLower().Contains(search) ||
                a.User.LastName.ToLower().Contains(search) ||
                a.Staff.FirstName.ToLower().Contains(search) ||
                a.Staff.LastName.ToLower().Contains(search));
        }

        query = request.OrderBy?.ToLower() switch
        {
            "status" => request.OrderDescending ? query.OrderByDescending(a => a.Status) : query.OrderBy(a => a.Status),
            _ => request.OrderDescending ? query.OrderByDescending(a => a.ScheduledAt) : query.OrderBy(a => a.ScheduledAt)
        };

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
