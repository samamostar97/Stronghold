namespace Stronghold.Application.DTOs.Reports;

/// <summary>Tab "Osoblje" - termini po trenerima i nutricionistima za odabrani period.</summary>
public class StaffReportResponse
{
    public int FromYear { get; set; }
    public int FromMonth { get; set; }
    public int ToYear { get; set; }
    public int ToMonth { get; set; }

    public int TotalAppointments { get; set; }
    public int CompletedCount { get; set; }
    public int CancelledCount { get; set; }

    /// <summary>Termini koji tek cekaju (Pending ili Confirmed).</summary>
    public int UpcomingCount { get; set; }

    public string? BusiestStaffName { get; set; }
    public int BusiestStaffCount { get; set; }

    /// <summary>Satnica s najvise termina u periodu; null kad nema termina.</summary>
    public int? BusiestHour { get; set; }
    public int BusiestHourCount { get; set; }

    public List<StaffAppointmentStat> Staff { get; set; } = new();
}

public class StaffAppointmentStat
{
    public string FullName { get; set; } = null!;
    public string StaffType { get; set; } = null!;
    public int TotalCount { get; set; }
    public int CompletedCount { get; set; }
    public int CancelledCount { get; set; }
    public int UpcomingCount { get; set; }
}
