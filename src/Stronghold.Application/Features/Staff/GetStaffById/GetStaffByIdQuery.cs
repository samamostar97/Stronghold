using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Staff.GetStaffById;

[AuthorizeRole("Admin")]
[AuthorizeRole("User")]
public class GetStaffByIdQuery : IRequest<StaffResponse>
{
    public int Id { get; set; }
}
