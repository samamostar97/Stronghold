namespace Stronghold.Application.DTOs.Response
{
    public class AdminAppointmentResponse
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int? TrainerId { get; set; }
        public int? NutritionistId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public string? TrainerName { get; set; }
        public string? NutritionistName { get; set; }
        public DateTime AppointmentDate { get; set; }
        public string Type { get; set; } = string.Empty;
    }
}
