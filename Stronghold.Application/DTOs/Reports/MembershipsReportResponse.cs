namespace Stronghold.Application.DTOs.Reports;

// Izvjestaj o clanarinama - sve uplate u periodu (od datuma do datuma), opciono za jednog clana.
public class MembershipsReportResponse
{
    public DateTime FromDate { get; set; }

    // Krajnji datum perioda (ukljucen).
    public DateTime ToDate { get; set; }

    // Popunjeno samo kad je izvjestaj filtriran po clanu.
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
