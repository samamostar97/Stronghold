namespace Stronghold.Application.Features.Appointments.DTOs;

public class AppointmentResponse
{
    public int Id { get; set; }
    public string? TrainerName { get; set; }
    public string? NutritionistName { get; set; }
    public DateTime AppointmentDate { get; set; }
}
