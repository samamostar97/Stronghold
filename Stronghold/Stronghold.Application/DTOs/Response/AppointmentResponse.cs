namespace Stronghold.Application.DTOs.Response
{
    public class AppointmentResponse
    {
        public int Id { get; set; }
        public string? TrainerName { get; set; }
        public string? NutritionistName { get; set; }
        public DateTime AppointmentDate { get; set; }
    }
}
