namespace Stronghold.Application.Features.Appointments.GetAvailableSlots;

public class AvailableSlotResponse
{
    public DateTime SlotTime { get; set; }
    public bool IsAvailable { get; set; }
}
