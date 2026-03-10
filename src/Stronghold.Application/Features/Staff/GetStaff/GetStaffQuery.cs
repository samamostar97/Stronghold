using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Staff.GetStaff;

[AuthorizeRole("Admin")]
[AuthorizeRole("User")]
public class GetStaffQuery : BaseQueryFilter, IRequest<PagedResult<StaffResponse>>
{
    public string? StaffType { get; set; }
}
