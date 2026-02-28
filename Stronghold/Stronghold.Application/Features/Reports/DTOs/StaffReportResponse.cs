namespace Stronghold.Application.Features.Reports.DTOs
{
    public class StaffReportResponse
    {
        public int TotalAppointments { get; set; }
        public int TrainerAppointments { get; set; }
        public int NutritionistAppointments { get; set; }
        public int TotalTrainers { get; set; }
        public int TotalNutritionists { get; set; }
        public List<StaffRankingItemResponse> StaffRanking { get; set; } = [];
    }

    public class StaffRankingItemResponse
    {
        public string Name { get; set; } = string.Empty;
        public int AppointmentCount { get; set; }
        public string Type { get; set; } = string.Empty;
    }
}
