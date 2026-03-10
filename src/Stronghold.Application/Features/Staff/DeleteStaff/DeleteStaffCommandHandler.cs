using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Staff.DeleteStaff;

public class DeleteStaffCommandHandler : IRequestHandler<DeleteStaffCommand, Unit>
{
    private readonly IStaffRepository _staffRepository;
    private readonly IAuditService _auditService;
    private readonly ICurrentUserService _currentUserService;

    public DeleteStaffCommandHandler(
        IStaffRepository staffRepository,
        IAuditService auditService,
        ICurrentUserService currentUserService)
    {
        _staffRepository = staffRepository;
        _auditService = auditService;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(DeleteStaffCommand request, CancellationToken cancellationToken)
    {
        var staff = await _staffRepository.GetByIdAsync(request.Id)
            ?? throw new NotFoundException("Osoblje", request.Id);

        await _auditService.LogDeleteAsync(_currentUserService.UserId, "Staff", staff.Id, staff);

        _staffRepository.Remove(staff);
        await _staffRepository.SaveChangesAsync();

        return Unit.Value;
    }
}
