namespace Stronghold.Application.DTOs.Reports;

/// <summary>Izvjestaj o clanarinama - sve uplate u periodu (od datuma do datuma), opciono za jednog clana.</summary>
public class MembershipsReportResponse
{
    public DateTime FromDate { get; set; }

    /// <summary>Krajnji datum perioda (ukljucen).</summary>
    public DateTime ToDate { get; set; }

    /// <summary>Popunjeno samo kad je izvjestaj filtriran po clanu.</summary>
    public string? UserFullName { get; set; }

    public decimal TotalAmount { get; set; }
    public int PaymentCount { get; set; }

    public List<PaymentRow> Payments { get; set; } = new();
}

public class PaymentRow
{
    public DateTime PaidAt { get; set; }
    public string UserFullName { get; set; } = null!;
    public string PackageName { get; set; } = null!;
    public decimal Amount { get; set; }
}
