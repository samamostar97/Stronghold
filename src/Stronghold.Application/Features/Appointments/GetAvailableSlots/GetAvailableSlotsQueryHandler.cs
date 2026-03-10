using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Enums;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Appointments.GetAvailableSlots;

public class GetAvailableSlotsQueryHandler : IRequestHandler<GetAvailableSlotsQuery, List<AvailableSlotResponse>>
{
    private readonly IAppointmentRepository _appointmentRepository;
    private readonly IStaffRepository _staffRepository;

    public GetAvailableSlotsQueryHandler(IAppointmentRepository appointmentRepository, IStaffRepository staffRepository)
    {
        _appointmentRepository = appointmentRepository;
        _staffRepository = staffRepository;
    }

    public async Task<List<AvailableSlotResponse>> Handle(GetAvailableSlotsQuery request, CancellationToken cancellationToken)
    {
        _ = await _staffRepository.GetByIdAsync(request.StaffId)
            ?? throw new NotFoundException("Osoblje", request.StaffId);

        var date = request.Date.Date;

        var bookedSlots = await _appointmentRepository.Query()
            .Where(a => a.StaffId == request.StaffId
                && a.ScheduledAt.Date == date
                && a.Status != AppointmentStatus.Rejected)
            .Select(a => a.ScheduledAt.Hour)
            .ToListAsync(cancellationToken);

        var slots = new List<AvailableSlotResponse>();
        for (var hour = 8; hour <= 16; hour++)
        {
            slots.Add(new AvailableSlotResponse
            {
                SlotTime = date.AddHours(hour),
                IsAvailable = !bookedSlots.Contains(hour)
            });
        }

        return slots;
    }
}
