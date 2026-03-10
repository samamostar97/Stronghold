using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Enums;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Staff.UpdateStaff;

public class UpdateStaffCommandHandler : IRequestHandler<UpdateStaffCommand, StaffResponse>
{
    private readonly IStaffRepository _staffRepository;

    public UpdateStaffCommandHandler(IStaffRepository staffRepository)
    {
        _staffRepository = staffRepository;
    }

    public async Task<StaffResponse> Handle(UpdateStaffCommand request, CancellationToken cancellationToken)
    {
        var staff = await _staffRepository.GetByIdAsync(request.Id)
            ?? throw new NotFoundException("Osoblje", request.Id);

        if (staff.Email != request.Email)
        {
            var existingByEmail = await _staffRepository.GetByEmailAsync(request.Email);
            if (existingByEmail != null)
                throw new ConflictException("Email je već registrovan.");
        }

        staff.FirstName = request.FirstName;
        staff.LastName = request.LastName;
        staff.Email = request.Email;
        staff.Phone = request.Phone;
        staff.Bio = request.Bio;
        staff.StaffType = Enum.Parse<StaffType>(request.StaffType, true);
        staff.IsActive = request.IsActive;

        _staffRepository.Update(staff);
        await _staffRepository.SaveChangesAsync();

        return StaffMappings.ToResponse(staff);
    }
}
