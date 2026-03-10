using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Staff.DeleteStaff;

[AuthorizeRole("Admin")]
public class DeleteStaffCommand : IRequest<Unit>
{
    public int Id { get; set; }
}
