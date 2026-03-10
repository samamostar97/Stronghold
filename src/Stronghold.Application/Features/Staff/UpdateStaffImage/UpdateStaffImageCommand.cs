using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Staff.UpdateStaffImage;

[AuthorizeRole("Admin")]
public class UpdateStaffImageCommand : IRequest<StaffResponse>
{
    public int Id { get; set; }
    public Stream FileStream { get; set; } = null!;
    public string FileName { get; set; } = string.Empty;
}
