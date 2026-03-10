using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Staff.GetStaff;

public class GetStaffQuery : BaseQueryFilter, IRequest<PagedResult<StaffResponse>>
{
    public string? StaffType { get; set; }
}
