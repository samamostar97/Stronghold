using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Staff.GetStaffById;

public class GetStaffByIdQueryHandler : IRequestHandler<GetStaffByIdQuery, StaffResponse>
{
    private readonly IStaffRepository _staffRepository;

    public GetStaffByIdQueryHandler(IStaffRepository staffRepository)
    {
        _staffRepository = staffRepository;
    }

    public async Task<StaffResponse> Handle(GetStaffByIdQuery request, CancellationToken cancellationToken)
    {
        var staff = await _staffRepository.GetByIdAsync(request.Id)
            ?? throw new NotFoundException("Osoblje", request.Id);

        return StaffMappings.ToResponse(staff);
    }
}
