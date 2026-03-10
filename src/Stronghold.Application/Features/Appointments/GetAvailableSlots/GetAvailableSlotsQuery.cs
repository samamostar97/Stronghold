using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Appointments.GetAvailableSlots;

[AuthorizeRole("Admin")]
[AuthorizeRole("User")]
public class GetAvailableSlotsQuery : IRequest<List<AvailableSlotResponse>>
{
    public int StaffId { get; set; }
    public DateTime Date { get; set; }
}
