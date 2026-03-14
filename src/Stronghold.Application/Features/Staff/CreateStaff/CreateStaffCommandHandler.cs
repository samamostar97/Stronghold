using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Enums;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Staff.CreateStaff;

public class CreateStaffCommandHandler : IRequestHandler<CreateStaffCommand, StaffResponse>
{
    private readonly IStaffRepository _staffRepository;

    public CreateStaffCommandHandler(IStaffRepository staffRepository)
    {
        _staffRepository = staffRepository;
    }

    public async Task<StaffResponse> Handle(CreateStaffCommand request, CancellationToken cancellationToken)
    {
        var fieldErrors = new Dictionary<string, string>();

        var existingByEmail = await _staffRepository.GetByEmailAsync(request.Email);
        if (existingByEmail != null)
            fieldErrors["email"] = "Email je već registrovan.";

        if (!string.IsNullOrWhiteSpace(request.Phone))
        {
            var existingByPhone = await _staffRepository.GetByPhoneAsync(request.Phone);
            if (existingByPhone != null)
                fieldErrors["phone"] = "Broj telefona je već registrovan.";
        }

        if (fieldErrors.Count > 0)
            throw new ConflictException(fieldErrors);

        var staff = new Domain.Entities.Staff
        {
            FirstName = request.FirstName,
            LastName = request.LastName,
            Email = request.Email,
            Phone = request.Phone,
            Bio = request.Bio,
            StaffType = Enum.Parse<StaffType>(request.StaffType, true)
        };

        await _staffRepository.AddAsync(staff);
        await _staffRepository.SaveChangesAsync();

        return StaffMappings.ToResponse(staff);
    }
}
