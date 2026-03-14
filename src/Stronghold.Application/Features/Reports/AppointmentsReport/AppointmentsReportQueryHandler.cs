using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Enums;

namespace Stronghold.Application.Features.Reports.AppointmentsReport;

public class AppointmentsReportQueryHandler : IRequestHandler<AppointmentsReportQuery, ReportResult>
{
    private readonly IAppointmentRepository _appointmentRepository;
    private readonly IReportService _reportService;

    public AppointmentsReportQueryHandler(
        IAppointmentRepository appointmentRepository,
        IReportService reportService)
    {
        _appointmentRepository = appointmentRepository;
        _reportService = reportService;
    }

    public async Task<ReportResult> Handle(AppointmentsReportQuery request, CancellationToken cancellationToken)
    {
        var appointments = await _appointmentRepository.QueryAll()
            .Include(a => a.Staff)
            .Where(a => a.ScheduledAt >= request.From && a.ScheduledAt <= request.To)
            .ToListAsync(cancellationToken);

        var staffStats = appointments
            .GroupBy(a => new { a.StaffId, a.Staff.FirstName, a.Staff.LastName, a.Staff.StaffType })
            .Select(g => new StaffAppointmentItem
            {
                StaffId = g.Key.StaffId,
                StaffName = $"{g.Key.FirstName} {g.Key.LastName}",
                StaffType = g.Key.StaffType.ToString(),
                TotalAppointments = g.Count(),
                Completed = g.Count(a => a.Status == AppointmentStatus.Completed),
                Approved = g.Count(a => a.Status == AppointmentStatus.Approved),
                Rejected = g.Count(a => a.Status == AppointmentStatus.Rejected),
                Pending = g.Count(a => a.Status == AppointmentStatus.Pending)
            })
            .OrderByDescending(s => s.TotalAppointments)
            .ToList();

        var data = new AppointmentsReportData
        {
            From = request.From,
            To = request.To,
            TotalAppointments = appointments.Count,
            StaffStats = staffStats
        };

        return request.Format.ToLower() == "excel"
            ? _reportService.GenerateAppointmentsReportExcel(data)
            : _reportService.GenerateAppointmentsReportPdf(data);
    }
}
