using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Staff.UpdateStaff;

[AuthorizeRole("Admin")]
public class UpdateStaffCommand : IRequest<StaffResponse>
{
    public int Id { get; set; }
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? Phone { get; set; }
    public string? Bio { get; set; }
    public string StaffType { get; set; } = string.Empty;
    public bool IsActive { get; set; }
}
