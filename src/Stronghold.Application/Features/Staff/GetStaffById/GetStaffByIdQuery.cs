using MediatR;

namespace Stronghold.Application.Features.Staff.GetStaffById;

public class GetStaffByIdQuery : IRequest<StaffResponse>
{
    public int Id { get; set; }
}
