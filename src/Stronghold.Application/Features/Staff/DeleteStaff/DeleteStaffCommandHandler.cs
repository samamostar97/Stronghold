using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Enums;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Staff.DeleteStaff;

public class DeleteStaffCommandHandler : IRequestHandler<DeleteStaffCommand, Unit>
{
    private readonly IStaffRepository _staffRepository;
    private readonly IAppointmentRepository _appointmentRepository;
    private readonly IAuditService _auditService;
    private readonly ICurrentUserService _currentUserService;

    public DeleteStaffCommandHandler(
        IStaffRepository staffRepository,
        IAppointmentRepository appointmentRepository,
        IAuditService auditService,
        ICurrentUserService currentUserService)
    {
        _staffRepository = staffRepository;
        _appointmentRepository = appointmentRepository;
        _auditService = auditService;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(DeleteStaffCommand request, CancellationToken cancellationToken)
    {
        var staff = await _staffRepository.GetByIdAsync(request.Id)
            ?? throw new NotFoundException("Osoblje", request.Id);

        var hasActiveAppointments = await _appointmentRepository.Query()
            .AnyAsync(a => a.StaffId == request.Id &&
                (a.Status == AppointmentStatus.Pending || a.Status == AppointmentStatus.Approved),
                cancellationToken);
        if (hasActiveAppointments)
            throw new ConflictException("Nije moguće obrisati osoblje koje ima aktivne termine.");

        await _auditService.LogDeleteAsync(_currentUserService.UserId, "Staff", staff.Id, staff);

        _staffRepository.Remove(staff);
        await _staffRepository.SaveChangesAsync();

        return Unit.Value;
    }
}
